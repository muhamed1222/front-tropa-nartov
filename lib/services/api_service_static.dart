import 'api_service.dart';
import '../core/network/dio_client.dart';
import '../models/api_models.dart' as api_models;

// Экспортируем типы для удобства, скрывая конфликтующие классы
export '../models/api_models.dart' hide Place, Review, Image;

/// Статическая обёртка для ApiServiceDio
/// Обеспечивает обратную совместимость для старого кода
class ApiService {
  static final ApiServiceDio _instance = ApiServiceDio(dio: createDio());

  // ==================== Places ====================
  static Future<List<api_models.Place>> getPlaces({
    List<int>? categoryIds,
    List<int>? typeIds,
    List<int>? areaIds,
    int page = 1,
    int limit = 20,
  }) {
    return _instance.getPlaces();
  }

  static Future<api_models.Place> getPlace(int id) {
    return _instance.getPlaceById(id);
  }

  // ==================== Routes ====================
  static Future<List<api_models.AppRoute>> getRoutes({int? limit, int? offset}) {
    return _instance.getRoutes(limit: limit, offset: offset);
  }

  static Future<api_models.AppRoute> getRoute(int id) {
    return _instance.getRouteById(id);
  }

  // ==================== Favorites - Places ====================
  static Future<List<api_models.Place>> getFavoritePlaces(String token) {
    return _instance.getFavoritePlaces(token);
  }

  static Future<bool> isPlaceFavorite(int placeId, String token) {
    return _instance.isPlaceFavorite(placeId, token);
  }

  static Future<void> addPlaceToFavorites(int placeId, String token) {
    return _instance.addPlaceToFavorites(placeId, token);
  }

  static Future<void> removePlaceFromFavorites(int placeId, String token) {
    return _instance.removePlaceFromFavorites(placeId, token);
  }

  // ==================== Favorites - Routes ====================
  static Future<List<api_models.AppRoute>> getFavoriteRoutes(String token) {
    return _instance.getFavoriteRoutes(token);
  }

  static Future<bool> isRouteFavorite(int routeId, String token) {
    return _instance.isRouteFavorite(routeId, token);
  }

  static Future<void> addRouteToFavorites(int routeId, String token) {
    return _instance.addRouteToFavorites(routeId, token);
  }

  static Future<void> removeRouteFromFavorites(int routeId, String token) {
    return _instance.removeRouteFromFavorites(routeId, token);
  }

  // ==================== Reviews ====================
  static Future<List<api_models.Review>> getPlaceReviews(int placeId) {
    return _instance.getReviewsForPlace(placeId);
  }

  static Future<List<api_models.Review>> getRouteReviews(int routeId) {
    return _instance.getReviewsForRoute(routeId);
  }

  static Future<void> createReview({
    required int placeId,
    required String text,
    required int rating,
    required String token,
  }) {
    return _instance.addReview(
      placeId: placeId,
      comment: text,
      rating: rating,
      token: token,
    );
  }

  // ==================== User Activity ====================
  static Future<List<api_models.PlaceActivity>> getVisitedPlaces(String token) {
    return _instance.getUserPlacesHistory(token);
  }

  static Future<List<api_models.RouteActivity>> getCompletedRoutes(String token) {
    return _instance.getUserRoutesHistory(token);
  }

  static Future<Map<String, int>> getUserStatistics(String token) {
    return _instance.getUserStatistics(token);
  }

  static Future<api_models.ActivityHistory> getUserActivityHistory(String token) {
    return _instance.getUserActivityHistory(token);
  }

  // ==================== User Profile ====================
  static Future<api_models.User> getUserProfile(String token) {
    return _instance.getProfile(token);
  }

  static Future<api_models.User> getProfile(String token) {
    return _instance.getProfile(token);
  }

  static Future<api_models.User> updateUserProfile(String firstName, String lastName, String email, String token) {
    return _instance.updateProfile(token, firstName, lastName, email);
  }

  static Future<void> changePassword(String oldPassword, String newPassword, String token) {
    return _instance.changePassword(oldPassword, newPassword);
  }

  static Future<void> deleteAccount(String token) {
    return _instance.deleteAccount(token);
  }

  // ==================== Auth ====================
  static Future<api_models.LoginResponse> login(String email, String password) {
    return _instance.login(email, password);
  }

  static Future<api_models.RegisterResponse> register(String name, String email, String password) {
    return _instance.register(name, email, password);
  }

  static Future<api_models.LoginResponse> refreshToken(String refreshToken) {
    return _instance.refreshToken(refreshToken);
  }

  // Password Recovery (stubbed - not yet implemented in backend)
  static Future<void> forgotPassword(String email) async {
    throw UnimplementedError('Password recovery not yet implemented. Please contact support.');
  }

  static Future<void> verifyResetCode(String code) async {
    throw UnimplementedError('Password recovery not yet implemented. Please contact support.');
  }

  static Future<void> resetPassword(String token, String newPassword) async {
    throw UnimplementedError('Password recovery not yet implemented. Please contact support.');
  }

  // ==================== Status ====================
  static Future<Map<int, bool>> getPlacesVisitStatus(List<int> placeIds, String token) {
    return _instance.getPlacesVisitStatus(placeIds, token);
  }

  static Future<Map<int, bool>> getFavoriteStatusesForRoutes(
    List<int> routeIds,
    String token,
  ) {
    return _instance.getFavoriteStatusesForRoutes(routeIds, token);
  }

  // ==================== Connection ====================
  static Future<bool> checkConnection() {
    return _instance.checkConnection();
  }

  // ==================== Aliases for backward compatibility ====================
  static Future<void> removeFromFavorites(int placeId, String token) {
    return _instance.removePlaceFromFavorites(placeId, token);
  }

  static Future<void> addToFavorites(int placeId, String token) {
    return _instance.addPlaceToFavorites(placeId, token);
  }
}
