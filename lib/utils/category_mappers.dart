class CategoryMapper {
  static String toEnumValue(String displayName) {
    if (displayToEnum.containsKey(displayName)) {
      return displayToEnum[displayName]!;
    }
    return displayName.replaceAll(' & ', '').replaceAll(' ', '');
  }

  static String toDisplayName(String enumValue) {
    if (enumToDisplay.containsKey(enumValue)) {
      return enumToDisplay[enumValue]!;
    }
    return enumValue;
  }

  static final Map<String, String> displayToEnum = {
    'Engineering': 'Engineering',
    'IT': 'IT',
    'Design': 'Design',
    'Medicine': 'Medicine',
    'Health & Beauty': 'HealthBeauty',
    'Farming & Agriculture': 'FarmingAgriculture',
    'Fashion': 'Fashion',
    'Leisure & Hospitality': 'LeisureHospitality',
    'Transport': 'Transport'
  };

  static final Map<String, String> enumToDisplay = Map.fromEntries(
    displayToEnum.entries.map((e) => MapEntry(e.value, e.key))
  );
}

class SubCategoryMapper {
  static String toEnumValue(String displayName) {
    if (displayToEnum.containsKey(displayName)) {
      return displayToEnum[displayName]!;
    }
    return displayName.replaceAll(' & ', '').replaceAll(' ', '');
  }

  static String toDisplayName(String enumValue) {
    if (enumToDisplay.containsKey(enumValue)) {
      return enumToDisplay[enumValue]!;
    }
    return enumValue;
  }

  static final Map<String, String> displayToEnum = {
        'General Medicine': 'GeneralMedicine',
    'Graphic Design': 'GraphicDesign',
    'Data Science': 'DataScience',
    'Civil': 'Civil',
    'Mechanical': 'Mechanical',
    'Electrical': 'Electrical', 
    'Architecture':'Architecture',
    'Painting': 'Painting',
    'Plumbing': 'Plumbing',
    'Exterior Design': 'ExteriorDesign',
    'Building & Construction': 'BuildingConstruction',
    'Interior Design': 'InteriorDesign',
    'AI': 'AI',
    'Software': 'Software',
    'Animation': 'Animation',
    'Illustration': 'Illustration',
    'Cardiology': 'Cardiology',
    'Pediatrics': 'Pediatrics',
    'Tours & Travel': 'ToursTravel',
    'Hotels': 'Hotels',
    'Rest Gardens': 'RestGardens',
    'Game Parks': 'GameParks',
    'Game Reserves': 'GameReserves',
    'Beaches': 'Beaches',
    'Camp Sites': 'CampSites',
    'Buses': 'Buses',
    'Car Hire & Rental': 'CarHireRental',
    'Boat Ride': 'BoatRide',
    'Hair Salons': 'HairSalons',
    'Saunas': 'Saunas',
    'Beauty Parlour': 'BeautyParlour',
    'Pedicure': 'Pedicure',
    'Manicure': 'Manicure',
    'Mens Ware': 'MensWare',
    'Womens Ware': 'WomesWare',
    'Poultry': 'Poultry',
    'Piggery': 'Piggery',
    'Goat Keeping': 'GoatFarming',
    'Cattle Keeping': 'CattleFarming',
    'Bee Farming': 'BeeFarming',
    'Fish Farming': 'FishFarming',
    'Bananas': 'Bananas',
    'Maize': 'Maize',
    'Beans': 'Beans',
  };

  static final Map<String, String> enumToDisplay = Map.fromEntries(
    displayToEnum.entries.map((e) => MapEntry(e.value, e.key))
  );
}