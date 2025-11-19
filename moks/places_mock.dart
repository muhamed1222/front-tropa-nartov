import 'models.dart';

// Моковые данные мест с полной информацией
final List<Place> mockPlaces = [
  Place(
    id: '1',
    name: 'Чегемские водопады',
    description: 'Величественные водопады в Чегемском ущелье. Зимой превращаются в ледяные столбы, создавая невероятное зрелище. Это одно из самых популярных мест для посещения в Кабардино-Балкарии.',
    address: 'Чегемский район, с. Верхний Чегем',
    latitude: 43.2945,
    longitude: 43.1829,
    hours: 'Круглосуточно',
    contacts: '+7 (928) 123-45-67',
    type: 'Природная достопримечательность',
    rating: 4.8,
    images: [
      ImageModel(
        id: '1',
        url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4',
        isMain: true,
        placeId: '1',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-01T00:00:00.000Z',
      ),
      ImageModel(
        id: '2',
        url: 'https://images.unsplash.com/photo-1519904981063-b0cf448d479e',
        isMain: false,
        placeId: '1',
        createdAt: '2024-01-01T00:00:00.000Z',
        updatedAt: '2024-01-01T00:00:00.000Z',
      ),
    ],
    reviews: [
      Review(
        id: '1',
        text: 'Потрясающее место! Водопады просто завораживают. Были зимой - ледяные столбы выглядят фантастически. Обязательно вернемся летом!',
        authorId: '1',
        authorName: 'Ахмед Карданов',
        authorAvatar: 'https://i.pravatar.cc/150?img=12',
        rating: '5',
        createdAt: '2024-08-15T00:00:00.000Z',
        updatedAt: '2024-08-15T00:00:00.000Z',
        placeId: '1',
        likes: 24,
      ),
      Review(
        id: '2',
        text: 'Красиво, но дорога непростая. Рекомендую хорошую обувь и теплую одежду, даже летом может быть прохладно.',
        authorId: '2',
        authorName: 'Мадина Бозиева',
        authorAvatar: 'https://i.pravatar.cc/150?img=25',
        rating: '4',
        createdAt: '2024-08-20T00:00:00.000Z',
        updatedAt: '2024-08-20T00:00:00.000Z',
        placeId: '1',
        likes: 12,
      ),
    ],
    typeId: 3,
    categoryId: 1,
    areaId: 2,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 9, 15),
  ),
  Place(
    id: '2',
    name: 'Голубые озера',
    description: 'Группа карстовых озер с удивительно чистой голубой водой. Нижнее Голубое озеро - одно из самых глубоких в России. Температура воды круглый год составляет +9°C.',
    address: 'Черекский район, Черекское ущелье',
    latitude: 43.3833,
    longitude: 43.5333,
    hours: '08:00-20:00',
    contacts: '+7 (928) 234-56-78',
    type: 'Природная достопримечательность',
    rating: 4.9,
    images: [
      ImageModel(
        id: '3',
        url: 'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
        isMain: true,
        placeId: '2',
        createdAt: '2024-01-05T00:00:00.000Z',
        updatedAt: '2024-01-05T00:00:00.000Z',
      ),
      ImageModel(
        id: '4',
        url: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29',
        isMain: false,
        placeId: '2',
        createdAt: '2024-01-05T00:00:00.000Z',
        updatedAt: '2024-01-05T00:00:00.000Z',
      ),
    ],
    reviews: [
      Review(
        id: '3',
        text: 'Невероятная красота! Цвет воды действительно удивительный. Глубина озера впечатляет. Место must-visit в КБР!',
        authorId: '3',
        authorName: 'Азамат Шогенов',
        authorAvatar: 'https://i.pravatar.cc/150?img=33',
        rating: '5',
        createdAt: '2024-08-22T00:00:00.000Z',
        updatedAt: '2024-08-22T00:00:00.000Z',
        placeId: '2',
        likes: 35,
      ),
    ],
    typeId: 3,
    categoryId: 1,
    areaId: 6,
    isActive: true,
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 9, 20),
  ),
  Place(
    id: '3',
    name: 'Национальный музей КБР',
    description: 'Крупнейший музей республики с богатой коллекцией экспонатов по истории, культуре и природе Кабардино-Балкарии. Здесь можно узнать о традициях народов Кавказа.',
    address: 'г. Нальчик, ул. Горького, 62',
    latitude: 43.4986,
    longitude: 43.6189,
    hours: '10:00-18:00, выходной - понедельник',
    contacts: '+7 (8662) 42-18-48',
    type: 'Музей',
    rating: 4.5,
    images: [
      ImageModel(
        id: '5',
        url: 'https://images.unsplash.com/photo-1582555172866-f73bb12a2ab3',
        isMain: true,
        placeId: '3',
        createdAt: '2024-01-10T00:00:00.000Z',
        updatedAt: '2024-01-10T00:00:00.000Z',
      ),
    ],
    reviews: [
      Review(
        id: '5',
        text: 'Отличный музей с богатой экспозицией. Узнал много нового об истории и культуре региона. Рекомендую взять экскурсию.',
        authorId: '5',
        authorName: 'Тимур Балкаров',
        authorAvatar: '',
        rating: '5',
        createdAt: '2024-09-05T00:00:00.000Z',
        updatedAt: '2024-09-05T00:00:00.000Z',
        placeId: '3',
        likes: 15,
      ),
    ],
    typeId: 2,
    categoryId: 3,
    areaId: 1,
    isActive: true,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 9, 10),
  ),
  Place(
    id: '4',
    name: 'Канатная дорога на Эльбрус',
    description: 'Современная канатная дорога, поднимающая на высоту до 3800 метров. Потрясающие виды на Кавказский хребет. Работает круглый год.',
    address: 'Эльбрусский район, поляна Азау',
    latitude: 43.2650,
    longitude: 42.4897,
    hours: '09:00-16:00',
    contacts: '+7 (928) 345-67-89',
    type: 'Смотровая площадка',
    rating: 4.7,
    images: [
      ImageModel(
        id: '6',
        url: 'https://images.unsplash.com/photo-1483197452165-7abc4b1a6d82',
        isMain: true,
        placeId: '4',
        createdAt: '2024-01-15T00:00:00.000Z',
        updatedAt: '2024-01-15T00:00:00.000Z',
      ),
    ],
    reviews: [
      Review(
        id: '6',
        text: 'Виды просто космические! Подъем плавный, кабинки комфортные. Наверху есть кафе. Советую приезжать в ясную погоду.',
        authorId: '1',
        authorName: 'Ахмед Карданов',
        authorAvatar: 'https://i.pravatar.cc/150?img=12',
        rating: '5',
        createdAt: '2024-09-10T00:00:00.000Z',
        updatedAt: '2024-09-10T00:00:00.000Z',
        placeId: '4',
        likes: 42,
      ),
    ],
    typeId: 6,
    categoryId: 4,
    areaId: 3,
    isActive: true,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 9, 25),
  ),
  Place(
    id: '5',
    name: 'Ресторан "Сосруко"',
    description: 'Панорамный ресторан на вершине горы с видом на Нальчик. Специализируется на блюдах национальной кухни. Особенно рекомендуем хычины и шашлык.',
    address: 'г. Нальчик, Атажукинский сад, гора Малая Кизиловка',
    latitude: 43.4805,
    longitude: 43.6067,
    hours: '11:00-23:00',
    contacts: '+7 (8662) 40-32-10',
    type: 'Ресторан',
    rating: 4.6,
    images: [
      ImageModel(
        id: '7',
        url: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
        isMain: true,
        placeId: '5',
        createdAt: '2024-01-20T00:00:00.000Z',
        updatedAt: '2024-01-20T00:00:00.000Z',
      ),
    ],
    reviews: [
      Review(
        id: '8',
        text: 'Шикарный вид на город! Кухня вкусная, порции большие. Особенно рекомендую хычины и шашлык. Персонал приветливый.',
        authorId: '3',
        authorName: 'Азамат Шогенов',
        authorAvatar: 'https://i.pravatar.cc/150?img=33',
        rating: '5',
        createdAt: '2024-09-08T00:00:00.000Z',
        updatedAt: '2024-09-08T00:00:00.000Z',
        placeId: '5',
        likes: 28,
      ),
    ],
    typeId: 4,
    categoryId: 5,
    areaId: 1,
    isActive: true,
    createdAt: DateTime(2024, 1, 20),
    updatedAt: DateTime(2024, 9, 5),
  ),
];

// Связи мест с тегами
final List<PlaceTag> mockPlaceTags = [
  PlaceTag(placeId: '1', tagId: 2), // Чегемские водопады - Водопады
  PlaceTag(placeId: '1', tagId: 5), // Природа
  PlaceTag(placeId: '1', tagId: 7), // Фотогеничное
  PlaceTag(placeId: '1', tagId: 8), // Доступно зимой
  
  PlaceTag(placeId: '2', tagId: 11), // Голубые озера - Озера
  PlaceTag(placeId: '2', tagId: 5), // Природа
  PlaceTag(placeId: '2', tagId: 7), // Фотогеничное
  
  PlaceTag(placeId: '3', tagId: 3), // Музей - История
  PlaceTag(placeId: '3', tagId: 4), // Культура
  PlaceTag(placeId: '3', tagId: 6), // Семейный отдых
  
  PlaceTag(placeId: '4', tagId: 9), // Канатная дорога - Эльбрус
  PlaceTag(placeId: '4', tagId: 1), // Горы
  PlaceTag(placeId: '4', tagId: 7), // Фотогеничное
  PlaceTag(placeId: '4', tagId: 12), // Экстрим
  
  PlaceTag(placeId: '5', tagId: 10), // Ресторан - Национальная кухня
  PlaceTag(placeId: '5', tagId: 7), // Фотогеничное
];