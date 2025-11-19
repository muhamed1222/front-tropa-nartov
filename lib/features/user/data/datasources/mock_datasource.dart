import 'package:tropanartov/features/user/domain/entities/user.dart';

class MockUserDatasource {
  final User mockUsers = User(
    id: '1',
    name: 'Иван Иванов',
    email: 'ivanov@example.com',
    passwordHash: 'hashed_password_1',
    avatar: 'https://picsum.photos/200?user=1',
    isActive: true,
    createdAt: '2023-01-01T10:00:00Z',
    updatedAt: '2023-01-10T12:00:00Z',
  );
}
