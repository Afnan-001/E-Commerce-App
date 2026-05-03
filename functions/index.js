const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");

admin.initializeApp();

const telegramBotToken = defineSecret("TELEGRAM_BOT_TOKEN");
const telegramChatId = defineSecret("TELEGRAM_CHAT_ID");

exports.notifyAdminOnNewOrder = onDocumentCreated(
  {
    document: "orders/{orderId}",
    region: "asia-south1",
    secrets: [telegramBotToken, telegramChatId],
  },
  async (event) => {
    const snapshot = event.data;
    const order = snapshot?.data();
    if (!order) {
      logger.warn("Order trigger fired without order data.");
      return;
    }

    const token = telegramBotToken.value().trim();
    const chatId = telegramChatId.value().trim();
    if (!token || !chatId) {
      logger.error(
        "Telegram notification skipped because TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is missing.",
      );
      return;
    }

    const message = buildOrderMessage({
      orderId: order.orderId || event.params.orderId,
      customerName:
        order.userName || order.customerName || order.deliveryAddress?.fullName,
      phone: order.userPhone || order.phoneNumber || order.deliveryAddress?.phone,
      total: order.pricing?.totalAmount ?? order.total,
      paymentMethod: order.payment?.paymentMethod ?? order.paymentMethod,
      paymentStatus: order.payment?.paymentStatus ?? order.paymentStatus,
      address:
        order.deliveryAddress?.fullAddress ||
        order.address ||
        composeAddress(order.deliveryAddress),
      items: Array.isArray(order.items) ? order.items : [],
    });

    const response = await fetch(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          chat_id: chatId,
          text: message,
          parse_mode: "HTML",
          disable_web_page_preview: true,
        }),
      },
    );

    if (!response.ok) {
      const body = await response.text();
      logger.error("Telegram notification failed.", {
        status: response.status,
        body,
      });
      return;
    }

    logger.info("Telegram notification sent for order.", {
      orderId: order.orderId || event.params.orderId,
    });
  },
);

exports.notifyAdminOnOrderCancelled = onDocumentUpdated(
  {
    document: "orders/{orderId}",
    region: "asia-south1",
    secrets: [telegramBotToken, telegramChatId],
  },
  async (event) => {
    const beforeOrder = event.data?.before?.data();
    const afterOrder = event.data?.after?.data();
    if (!afterOrder) {
      logger.warn("Order update trigger fired without updated order data.");
      return;
    }

    const beforeStatus = String(
      beforeOrder?.orderStatus || beforeOrder?.status || "",
    ).trim();
    const afterStatus = String(
      afterOrder.orderStatus || afterOrder.status || "",
    ).trim();

    if (afterStatus !== "cancelled" || beforeStatus === "cancelled") {
      return;
    }

    const token = telegramBotToken.value().trim();
    const chatId = telegramChatId.value().trim();
    if (!token || !chatId) {
      logger.error(
        "Telegram cancellation notification skipped because TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID is missing.",
      );
      return;
    }

    const message = buildOrderCancelledMessage({
      orderId: afterOrder.orderId || event.params.orderId,
      customerName:
        afterOrder.userName ||
        afterOrder.customerName ||
        afterOrder.deliveryAddress?.fullName,
      phone:
        afterOrder.userPhone ||
        afterOrder.phoneNumber ||
        afterOrder.deliveryAddress?.phone,
      total: afterOrder.pricing?.totalAmount ?? afterOrder.total,
      paymentMethod:
        afterOrder.payment?.paymentMethod ?? afterOrder.paymentMethod,
      paymentStatus:
        afterOrder.payment?.paymentStatus ?? afterOrder.paymentStatus,
      address:
        afterOrder.deliveryAddress?.fullAddress ||
        afterOrder.address ||
        composeAddress(afterOrder.deliveryAddress),
      items: Array.isArray(afterOrder.items) ? afterOrder.items : [],
    });

    const response = await fetch(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          chat_id: chatId,
          text: message,
          parse_mode: "HTML",
          disable_web_page_preview: true,
        }),
      },
    );

    if (!response.ok) {
      const body = await response.text();
      logger.error("Telegram cancellation notification failed.", {
        status: response.status,
        body,
      });
      return;
    }

    logger.info("Telegram cancellation notification sent for order.", {
      orderId: afterOrder.orderId || event.params.orderId,
    });
  },
);

function buildOrderMessage({
  orderId,
  customerName,
  phone,
  total,
  paymentMethod,
  paymentStatus,
  address,
  items,
}) {
  const itemLines = items.length
    ? items
        .slice(0, 10)
        .map((item) => {
          const name = escapeHtml(item.productName || item.name || "Item");
          const qty = item.quantity ?? 1;
          const amount = formatMoney(item.lineTotal ?? item.productPrice ?? 0);
          return `• ${name} x${qty} - ${amount}`;
        })
        .join("\n")
    : "• Items not available";

  const extraItems =
    items.length > 10 ? `\n• +${items.length - 10} more item(s)` : "";

  return [
    "🛒 <b>New order received</b>",
    `Order ID: <b>${escapeHtml(orderId || "N/A")}</b>`,
    `Customer: ${escapeHtml(customerName || "N/A")}`,
    `Phone: ${escapeHtml(phone || "N/A")}`,
    `Total: <b>${formatMoney(total)}</b>`,
    `Payment: ${escapeHtml(normalizeLabel(paymentMethod))}`,
    `Payment status: ${escapeHtml(normalizeLabel(paymentStatus))}`,
    "",
    "<b>Delivery address</b>",
    escapeHtml(address || "N/A"),
    "",
    "<b>Items</b>",
    `${itemLines}${extraItems}`,
  ].join("\n");
}

function buildOrderCancelledMessage({
  orderId,
  customerName,
  phone,
  total,
  paymentMethod,
  paymentStatus,
  address,
  items,
}) {
  const itemLines = items.length
    ? items
        .slice(0, 10)
        .map((item) => {
          const name = escapeHtml(item.productName || item.name || "Item");
          const qty = item.quantity ?? 1;
          return `• ${name} x${qty}`;
        })
        .join("\n")
    : "• Items not available";

  const extraItems =
    items.length > 10 ? `\n• +${items.length - 10} more item(s)` : "";

  return [
    "❌ <b>Order cancelled</b>",
    `Order ID: <b>${escapeHtml(orderId || "N/A")}</b>`,
    `Customer: ${escapeHtml(customerName || "N/A")}`,
    `Phone: ${escapeHtml(phone || "N/A")}`,
    `Total: <b>${formatMoney(total)}</b>`,
    `Payment: ${escapeHtml(normalizeLabel(paymentMethod))}`,
    `Payment status: ${escapeHtml(normalizeLabel(paymentStatus))}`,
    "",
    "<b>Delivery address</b>",
    escapeHtml(address || "N/A"),
    "",
    "<b>Items</b>",
    `${itemLines}${extraItems}`,
  ].join("\n");
}

function composeAddress(deliveryAddress) {
  if (!deliveryAddress || typeof deliveryAddress !== "object") {
    return "";
  }

  return [
    deliveryAddress.addressLine1,
    deliveryAddress.addressLine2,
    deliveryAddress.city,
    deliveryAddress.state,
    deliveryAddress.pincode,
    deliveryAddress.landmark,
  ]
    .filter(Boolean)
    .join(", ");
}

function normalizeLabel(value) {
  const raw = String(value || "").trim();
  if (!raw) {
    return "N/A";
  }

  return raw
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function formatMoney(value) {
  const amount = Number(value || 0);
  if (!Number.isFinite(amount)) {
    return "Rs 0";
  }
  return `Rs ${amount.toFixed(0)}`;
}

function escapeHtml(value) {
  return String(value || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}
