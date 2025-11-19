import 'models.dart';

// Моковые данные маршрутов
final List<Route> mockRoutes = [
  Route(
    id: '1',
    name: 'К подножию Эльбруса',
    description: 'Автомобильный маршрут от Нальчика до поляны Азау через Баксанское ущелье. Включает остановки у основных достопримечательностей.',
    length: 120.5,
    typeId: 2, // Автомобильный
    areaId: 1, // Эльбрусский
    rating: 4.9,
    isActive: true,
    points: [
      RoutePoint(latitude: 43.4858, longitude: 43.6045, order: 1, name: 'Нальчик, Атажукинский сад'),
      RoutePoint(latitude: 43.2333, longitude: 42.6333, order: 2, name: 'Баксанское ущелье'),
      RoutePoint(latitude: 43.2650, longitude: 42.4897, order: 3, name: 'Поляна Азау'),
    ],
    createdAt: DateTime(2024, 3, 1),
    updatedAt: DateTime(2024, 9, 20),
  ),
  Route(
    id: '2',
    name: 'Водопады и озера Чегема',
    description: 'Однодневный автомобильно-пешеходный маршрут по Чегемскому ущелью с посещением водопадов и близлежащих озер.',
    length: 45.8,
    typeId: 4, // Комбинированный
    areaId: 3, // Чегемский
    rating: 4.7,
    isActive: true,
    points: [
      RoutePoint(latitude: 43.4986, longitude: 43.6189, order: 1, name: 'Нальчик, центр'),
      RoutePoint(latitude: 43.2945, longitude: 43.1829, order: 2, name: 'Чегемские водопады'),
      RoutePoint(latitude: 43.3100, longitude: 43.3000, order: 3, name: 'Озера Чегема'),
      RoutePoint(latitude: 43.4986, longitude: 43.6189, order: 4, name: 'Возвращение в Нальчик'),
    ],
    createdAt: DateTime(2024, 3, 5),
    updatedAt: DateTime(2024, 9, 15),
  ),
  Route(
    id: '3',
    name: 'Исторический центр Нальчика',
    description: 'Пешеходная экскурсия по историческому центру города с посещением музеев, памятников и парков.',
    length: 5.2,
    typeId: 1, // Пеший
    areaId: 5, // Городской
    rating: 4.4,
    isActive: true,
    points: [
      RoutePoint(latitude: 43.4950, longitude: 43.6078, order: 1, name: 'Отель Sindika'),
      RoutePoint(latitude: 43.4986, longitude: 43.6189, order: 2, name: 'Национальный музей КБР'),
      RoutePoint(latitude: 43.4921, longitude: 43.6089, order: 3, name: 'Памятник Нартам'),
    ],
    createdAt: DateTime(2024, 3, 10),
    updatedAt: DateTime(2024, 9, 10),
  ),
  Route(
    id: '4',
    name: 'Голубые озера и Черекское ущелье',
    description: 'Автомобильный маршрут к знаменитым Голубым озерам с остановками на смотровых площадках.',
    length: 68.3,
    typeId: 2,
    areaId: 4, // Черекский
    rating: 4.8,
    isActive: true,
    points: [
      RoutePoint(latitude: 43.4986, longitude: 43.6189, order: 1, name: 'Нальчик, центр'),
      RoutePoint(latitude: 43.4167, longitude: 42.7833, order: 2, name: 'Долина Нарзанов'),
      RoutePoint(latitude: 43.3833, longitude: 43.5333, order: 3, name: 'Голубые озера'),
      RoutePoint(latitude: 43.4986, longitude: 43.6189, order: 4, name: 'Возвращение в Нальчик'),
    ],
    createdAt: DateTime(2024, 3, 15),
    updatedAt: DateTime(2024, 9, 18),
  ),
];

// Остановки маршрутов
final List<RouteStop> mockRouteStops = [
  // Маршрут 1: К подножию Эльбруса
  RouteStop(
    id: '1',
    routeId: '1',
    placeId: '4', // Канатная дорога
    orderNum: 1,
    createdAt: DateTime(2024, 3, 1),
  ),
  
  // Маршрут 2: Водопады и озера Чегема
  RouteStop(
    id: '2',
    routeId: '2',
    placeId: '1', // Чегемские водопады
    orderNum: 1,
    createdAt: DateTime(2024, 3, 5),
  ),
  
  // Маршрут 3: Исторический центр Нальчика
  RouteStop(
    id: '3',
    routeId: '3',
    placeId: '3', // Национальный музей
    orderNum: 1,
    createdAt: DateTime(2024, 3, 10),
  ),
  RouteStop(
    id: '4',
    routeId: '3',
    placeId: '5', // Ресторан Сосруко
    orderNum: 2,
    createdAt: DateTime(2024, 3, 10),
  ),
  
  // Маршрут 4: Голубые озера
  RouteStop(
    id: '5',
    routeId: '4',
    placeId: '2', // Голубые озера
    orderNum: 1,
    createdAt: DateTime(2024, 3, 15),
  ),
];

// Теги маршрутов
final List<RouteTag> mockRouteTags = [
  RouteTag(routeId: '1', tagId: 9), // К Эльбрусу - Эльбрус
  RouteTag(routeId: '1', tagId: 1), // Горы
  RouteTag(routeId: '1', tagId: 5), // Природа
  RouteTag(routeId: '1', tagId: 7), // Фотогеничное
  
  RouteTag(routeId: '2', tagId: 2), // Водопады Чегема - Водопады
  RouteTag(routeId: '2', tagId: 5), // Природа
  RouteTag(routeId: '2', tagId: 6), // Семейный отдых
  
  RouteTag(routeId: '3', tagId: 3), // Исторический центр - История
  RouteTag(routeId: '3', tagId: 4), // Культура
  RouteTag(routeId: '3', tagId: 6), // Семейный отдых
  
  RouteTag(routeId: '4', tagId: 11), // Голубые озера - Озера
  RouteTag(routeId: '4', tagId: 5), // Природа
  RouteTag(routeId: '4', tagId: 7), // Фотогеничное
];

// Изображения маршрутов
final List<ImageModel> mockRouteImages = [
  ImageModel(
    id: '13',
    url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
    isMain: true,
    routeId: '1',
    createdAt: '2024-03-01T00:00:00.000Z',
    updatedAt: '2024-03-01T00:00:00.000Z',
  ),
  ImageModel(
    id: '15',
    url: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
    isMain: true,
    routeId: '2',
    createdAt: '2024-03-05T00:00:00.000Z',
    updatedAt: '2024-03-05T00:00:00.000Z',
  ),
  ImageModel(
    id: '16',
    url: 'https://images.unsplash.com/photo-1477346611705-65d1883cee1e',
    isMain: true,
    routeId: '3',
    createdAt: '2024-03-10T00:00:00.000Z',
    updatedAt: '2024-03-10T00:00:00.000Z',
  ),
  ImageModel(
    id: '17',
    url: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29',
    isMain: true,
    routeId: '4',
    createdAt: '2024-03-15T00:00:00.000Z',
    updatedAt: '2024-03-15T00:00:00.000Z',
  ),
];