import 'package:shop/models/app_user_model.dart';

abstract class AuthRepository {
  Future<AppUserModel?> getCurrentUser();
}

class DemoAuthRepository implements AuthRepository {
  const DemoAuthRepository();

  @override
  Future<AppUserModel?> getCurrentUser() async {
    return null;
  }
}
