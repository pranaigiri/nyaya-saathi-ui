import '../../data/models/caste_type.dart';

const List<CasteType> localCasteTypes = [
  CasteType(
    casteTypeId: 1,
    casteTypeCode: 'CT_SC',
    casteTypeName: 'Scheduled Caste',
    description: 'Scheduled Caste community certificate holder',
    isActive: true,
    displayOrder: 1,
  ),
  CasteType(
    casteTypeId: 2,
    casteTypeCode: 'CT_ST',
    casteTypeName: 'Scheduled Tribe',
    description: 'Scheduled Tribe community certificate holder',
    isActive: true,
    displayOrder: 2,
  ),
];
