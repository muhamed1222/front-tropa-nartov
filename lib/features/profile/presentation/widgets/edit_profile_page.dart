import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../models/api_models.dart';
import '../../../../screens/auth/login_screen.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import 'change_password_dialog.dart' show showChangePasswordDialog;
import 'edit_profile_action_bar.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const EditProfilePage({super.key, this.onProfileUpdated});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _avatarImage;
  String? _avatarUrl;
  bool _isAvatarLoading = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUser();
      if (user != null) {
        setState(() {
          _firstNameController.text = user.name;
          _lastNameController.text = user.firstName;
          _emailController.text = user.email;
          // Загружаем URL аватарки, если есть
          _avatarUrl = _getAvatarUrlFromUser(user);
          _isLoading = false;
        });
      } else {
        // Если пользователя нет в локальном хранилище, загружаем с сервера
        final profile = await AuthService.getProfile();
        setState(() {
          _firstNameController.text = profile.name;
          _lastNameController.text = profile.firstName;
          _emailController.text = profile.email;
          _avatarUrl = _getAvatarUrlFromUser(profile);
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.loadError('User Data for Edit Profile', e, stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

// Метод для получения URL аватарки из данных пользователя
  String? _getAvatarUrlFromUser(User user) {
    // Если у пользователя есть avatar_url, формируем полный URL
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      // Проверяем, является ли URL уже полным (содержит baseUrl)
      if (user.avatarUrl!.startsWith('http')) {
        return user.avatarUrl;
      } else {
        // Добавляем baseUrl к относительному пути
        return '${ApiService.baseUrl}${user.avatarUrl}';
      }
    }
    return null;
  }

  // Метод для показа диалога выбора источника фото
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          title: 'Выберите источник',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Камера'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
          confirmText: null,
          cancelText: null,
          showCloseButton: true,
        );
      },
    );
  }

  // Метод для загрузки аватарки на сервер
  Future<void> _uploadAvatar(File imageFile) async {
    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Пользователь не авторизован');
      }


      // Создаем multipart запрос
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiService.baseUrl}/auth/upload-avatar')
      );

      // Добавляем заголовок авторизации
      request.headers['Authorization'] = 'Bearer $token';

      // Добавляем файл
      request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            imageFile.path,
            filename: 'avatar.jpg',
          )
      );


      // Отправляем запрос
      var response = await request.send();


      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);


        // Получаем URL аватарки из ответа
        final avatarUrlFromServer = jsonResponse['avatar_url'];
        if (avatarUrlFromServer != null) {
          // Формируем полный URL
          final fullAvatarUrl = '${ApiService.baseUrl}$avatarUrlFromServer';


          setState(() {
            _avatarUrl = fullAvatarUrl;
            _avatarImage = null; // Очищаем локальный файл, т.к. теперь используем URL с сервера
          });

          // Обновляем данные пользователя в локальном хранилище
          try {
            final updatedUser = await AuthService.getProfile();
            await AuthService.saveUser(updatedUser);

          } catch (e, stackTrace) {
            AppLogger.error('Update local user data after avatar upload', e, stackTrace);
          }

        } else {
          throw Exception('URL аватарки не получен от сервера');
        }
      } else {
        final errorResponse = await response.stream.bytesToString();
        AppLogger.apiError('/auth/upload-avatar', Exception('Status: ${response.statusCode}, Response: $errorResponse'));
        throw Exception('Ошибка загрузки аватарки: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Upload avatar', e, stackTrace);
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка загрузки аватарки');
      }
    } finally {
      setState(() {
        _isAvatarLoading = false;
      });
    }
  }

  // Метод для выбора фото из галереи
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {

        setState(() {
          _avatarImage = File(image.path);
          _avatarUrl = null;
        });

        await _uploadAvatar(_avatarImage!);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Pick image from gallery', e, stackTrace);
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка выбора изображения');
      }
    }
  }

// Метод для съемки фото
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _avatarImage = File(image.path);
          _avatarUrl = null;
        });

        // Автоматически загружаем на сервер
        await _uploadAvatar(_avatarImage!);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Take photo', e, stackTrace);
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка съемки фото');
      }
    }
  }

  // Метод для удаления аватарки
  Future<void> _deleteAvatar() async {
    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/auth/delete-avatar'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _avatarImage = null;
          _avatarUrl = null;
        });

        // Обновляем данные пользователя в локальном хранилище
        final updatedUser = await AuthService.getProfile();
        await AuthService.saveUser(updatedUser);

      } else {
        throw Exception('Ошибка удаления аватарки: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Delete avatar', e, stackTrace);
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка удаления аватарки');
      }
    } finally {
      setState(() {
        _isAvatarLoading = false;
      });
    }
  }

  // Виджет для отображения аватарки
  Widget _buildAvatar() {
    if (_isAvatarLoading) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
          color: AppDesignSystem.greyPlaceholder,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_avatarImage != null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
          image: DecorationImage(
            image: FileImage(_avatarImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
        child: CachedNetworkImage(
          imageUrl: _avatarUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 120,
            height: 120,
            color: AppDesignSystem.greyPlaceholder,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppDesignSystem.primaryColor,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 120,
            height: 120,
            color: AppDesignSystem.greyPlaceholder,
            child: Icon(
              Icons.person,
              size: 60,
              color: AppDesignSystem.greyColor,
            ),
          ),
        ),
      );
    }

    // Аватар по умолчанию
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
        color: AppDesignSystem.greyPlaceholder,
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: AppDesignSystem.greyColor,
      ),
    );
  }

  void _changePassword() {
    showChangePasswordDialog(context);
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.transparent),
            ),
            Center(
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 20),
              child: Container(
                width: MediaQuery.of(context).size.width - (AppDesignSystem.paddingHorizontal * 2),
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                  color: AppDesignSystem.whiteColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Вы действительно хотите удалить профиль?',
                      style: AppTextStyles.title(
                        fontWeight: AppDesignSystem.fontWeightSemiBold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                      const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppDesignSystem.backgroundColorSecondary,
                                borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                              ),
                              child: Center(
                                child: Text(
                                  'Нет',
                                  style: AppTextStyles.body(
                                    fontWeight: AppDesignSystem.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              try {
                                await AuthService.deleteAccount();
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                if (!context.mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const AuthLoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              } catch (e, stackTrace) {
                                AppLogger.error('Delete account', e, stackTrace);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                if (!context.mounted) return;
                                AppSnackBar.showError(context, 'Ошибка удаления профиля');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppDesignSystem.errorColor,
                                borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                              ),
                              child: Center(
                                child: Text(
                                  'Да',
                                  style: AppTextStyles.body(
                                    color: AppDesignSystem.whiteColor,
                                    fontWeight: AppDesignSystem.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    // Валидация имени
    if (_firstNameController.text.trim().isEmpty) {
      if (mounted) {
        AppSnackBar.showError(context, 'Поле "Имя" не может быть пустым');
      }
      return;
    }

    // Валидация email
    if (_emailController.text.trim().isEmpty) {
      if (mounted) {
        AppSnackBar.showError(context, 'Поле "Email" не может быть пустым');
      }
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      if (mounted) {
        AppSnackBar.showError(context, 'Введите корректный email адрес');
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final user = await AuthService.updateProfile(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
      );

      await AuthService.saveUser(user);

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!();
      }

      if (!mounted) return;
      AppSnackBar.showSuccess(context, 'Профиль успешно обновлен');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      AppLogger.error('Save profile', e, stackTrace);
      if (mounted) {
        AppSnackBar.showError(context, 'Ошибка обновления профиля');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.2,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [1.0],
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipPath(
          clipper: SmoothBorderClipper(radius: AppDesignSystem.borderRadiusLarge),
          child: Container(
            decoration: const BoxDecoration(
              color: AppDesignSystem.backgroundColor,
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Индикатор перетаскивания на самом верху с отступом 8px
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: DragIndicator(
                            color: AppDesignSystem.handleBarColor,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            left: AppDesignSystem.paddingHorizontal,
                            right: AppDesignSystem.paddingHorizontal,
                            bottom: AppDesignSystem.spacingXXLarge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                        const SizedBox(height: 26),
                        Center(
                          child: Text(
                            'Редактирование профиля',
                            style: AppTextStyles.title(),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Фото профиля с кнопками
                        Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Аватар
                            _buildAvatar(),

                            // Кнопки по вертикали по центру справа
                            Positioned(
                              right: -10,
                              top: 0,
                              bottom: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Кнопка изменения фото (камера)
                                  GestureDetector(
                                    onTap: _showImageSourceDialog,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppDesignSystem.primaryColor.withValues(alpha: 0.6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SvgPicture.asset(
                                          'assets/picture.svg',
                                          width: 4,
                                          height: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: AppDesignSystem.spacingTiny),
                                  // Кнопка удаления фото (мусорка)
                                  GestureDetector(
                                    onTap: _deleteAvatar,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: AppDesignSystem.primaryColor.withValues(alpha: 0.6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SvgPicture.asset(
                                          'assets/trash.svg',
                                          width: 4,
                                          height: 4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacingHuge + 2),

                      Text(
                        'Личные данные',
                        style: AppTextStyles.body(
                          fontWeight: AppDesignSystem.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: 10),

                      AppInputField(
                        controller: _firstNameController,
                        hint: 'Имя',
                      ),
                      SizedBox(height: AppDesignSystem.spacingSmall + 4),

                      AppInputField(
                        controller: _lastNameController,
                        hint: 'Фамилия',
                      ),
                      SizedBox(height: AppDesignSystem.spacingSmall + 4),

                      AppInputField(
                        controller: _emailController,
                        hint: 'Email',
                      ),
                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: _changePassword,
                        child: Text(
                          'Изменить пароль',
                          style: AppTextStyles.small(
                            color: AppDesignSystem.textColorSecondary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacingXXLarge),

                      GestureDetector(
                        onTap: () {_showExitConfirmationDialog(context);},
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                            color: AppDesignSystem.backgroundColorSecondary,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/trash.svg',
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  AppDesignSystem.errorColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: AppDesignSystem.spacingSmall),
                              Text(
                                'Удалить профиль',
                                style: AppTextStyles.body(
                                  color: AppDesignSystem.errorColor,
                                  fontWeight: AppDesignSystem.fontWeightMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacingHuge + 10),
                            ],
                          ),
                        ),
                      ),
                      // Кнопки внизу
                      EditProfileActionBar(
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                        onSave: _saveProfile,
                        isSaving: _isSaving,
                      ),
                    ],
                  ),
            ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}