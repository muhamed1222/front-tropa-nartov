import 'models.dart';

// Справочник: Типы мест
final List<TypeOfPlace> mockTypesOfPlaces = [
  TypeOfPlace(
    id: 1,
    name: 'Памятник',
    description: 'Исторические и культурные памятники',
  ),
  TypeOfPlace(
    id: 2,
    name: 'Музей',
    description: 'Музеи и выставочные центры',
  ),
  TypeOfPlace(
    id: 3,
    name: 'Природная достопримечательность',
    description: 'Водопады, горы, озера и другие природные объекты',
  ),
  TypeOfPlace(
    id: 4,
    name: 'Ресторан',
    description: 'Рестораны национальной кухни',
  ),
  TypeOfPlace(
    id: 5,
    name: 'Отель',
    description: 'Гостиницы и отели',
  ),
  TypeOfPlace(
    id: 6,
    name: 'Смотровая площадка',
    description: 'Места с панорамным видом',
  ),
];

// Справочник: Категории мест
final List<CategoryOfPlace> mockCategoriesOfPlaces = [
  CategoryOfPlace(
    id: 1,
    name: 'Экотуризм',
    description: 'Туризм с акцентом на природу и экологию',
  ),
  CategoryOfPlace(
    id: 2,
    name: 'Агротуризм',
    description: 'Знакомство с сельским хозяйством и традициями',
  ),
  CategoryOfPlace(
    id: 3,
    name: 'Культурный туризм',
    description: 'Исторические и культурные объекты',
  ),
  CategoryOfPlace(
    id: 4,
    name: 'Активный отдых',
    description: 'Спорт, альпинизм, трекинг',
  ),
  CategoryOfPlace(
    id: 5,
    name: 'Гастрономия',
    description: 'Национальная кухня и кулинарные традиции',
  ),
];

// Справочник: Районы мест
final List<AreaOfPlace> mockAreasOfPlaces = [
  AreaOfPlace(
    id: 1,
    name: 'Нальчик',
    description: 'Столица Кабардино-Балкарии',
  ),
  AreaOfPlace(
    id: 2,
    name: 'Чегемский район',
    description: 'Район с известными Чегемскими водопадами',
  ),
  AreaOfPlace(
    id: 3,
    name: 'Эльбрусский район',
    description: 'Район Эльбруса и горнолыжных курортов',
  ),
  AreaOfPlace(
    id: 4,
    name: 'Баксанский район',
    description: 'Район Баксанского ущелья',
  ),
  AreaOfPlace(
    id: 5,
    name: 'Зольский район',
    description: 'Горный район с живописными пейзажами',
  ),
  AreaOfPlace(
    id: 6,
    name: 'Черекский район',
    description: 'Район Голубых озер',
  ),
];

// Справочник: Типы маршрутов
final List<TypeOfRoute> mockTypesOfRoutes = [
  TypeOfRoute(
    id: 1,
    name: 'Пеший',
    description: 'Пешие маршруты',
  ),
  TypeOfRoute(
    id: 2,
    name: 'Автомобильный',
    description: 'Маршруты на автомобиле',
  ),
  TypeOfRoute(
    id: 3,
    name: 'Велосипедный',
    description: 'Велосипедные маршруты',
  ),
  TypeOfRoute(
    id: 4,
    name: 'Комбинированный',
    description: 'Смешанный тип маршрута',
  ),
];

// Справочник: Районы маршрутов
final List<AreaOfRoute> mockAreasOfRoutes = [
  AreaOfRoute(
    id: 1,
    name: 'Эльбрусский',
    description: 'Район Эльбруса',
  ),
  AreaOfRoute(
    id: 2,
    name: 'Зольский',
    description: 'Зольский район',
  ),
  AreaOfRoute(
    id: 3,
    name: 'Чегемский',
    description: 'Чегемский район',
  ),
  AreaOfRoute(
    id: 4,
    name: 'Черекский',
    description: 'Черекский район',
  ),
  AreaOfRoute(
    id: 5,
    name: 'Городской',
    description: 'Маршруты по городу Нальчик',
  ),
];

// Справочник: Теги
final List<Tag> mockTags = [
  Tag(id: 1, name: 'Горы', description: 'Горные районы'),
  Tag(id: 2, name: 'Водопады', description: 'Водопады'),
  Tag(id: 3, name: 'История', description: 'Исторические места'),
  Tag(id: 4, name: 'Культура', description: 'Культурные объекты'),
  Tag(id: 5, name: 'Природа', description: 'Природные объекты'),
  Tag(id: 6, name: 'Семейный отдых', description: 'Подходит для семей с детьми'),
  Tag(id: 7, name: 'Фотогеничное', description: 'Отличное место для фото'),
  Tag(id: 8, name: 'Доступно зимой', description: 'Доступно в зимний период'),
  Tag(id: 9, name: 'Эльбрус', description: 'Связано с Эльбрусом'),
  Tag(id: 10, name: 'Национальная кухня', description: 'Традиционная кухня'),
  Tag(id: 11, name: 'Озера', description: 'Озера и водоемы'),
  Tag(id: 12, name: 'Экстрим', description: 'Экстремальный отдых'),
];
