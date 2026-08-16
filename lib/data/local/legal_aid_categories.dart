import '../../models/legal_aid_category.dart';

const List<LegalAidCategory> localLegalAidCategories = [
  LegalAidCategory(
    id: '5793c5e6-9236-4dfd-8b82-fbb3d82dc092',
    categoryCode: 'SC_ST',
    categoryName: 'Scheduled Caste or Scheduled Tribe',
    description: 'Members of Scheduled Caste or Scheduled Tribe communities',
    displayOrder: 1,
  ),
  LegalAidCategory(
    id: '837cce7d-b165-42d1-b6c8-7bcbcce502d1',
    categoryCode: 'WOMAN',
    categoryName: 'Woman',
    description: 'All women are eligible regardless of income',
    displayOrder: 2,
  ),
  LegalAidCategory(
    id: '37dbfb26-af99-4ea8-a756-c668bf7abe2a',
    categoryCode: 'CHILDREN',
    categoryName: 'Children',
    description: 'All children are eligible',
    displayOrder: 3,
  ),
  LegalAidCategory(
    id: '6d4367bd-b8ba-4509-935a-d56e3501ed6d',
    categoryCode: 'DISABLED_PERSON',
    categoryName: 'Mentally Ill or Disabled Person',
    description: 'Persons with mental illness or physical disabilities',
    displayOrder: 4,
  ),
  LegalAidCategory(
    id: 'ec9e7d1a-b486-4a33-afc6-1b3cb465c6cc',
    categoryCode: 'DISASTER_VICTIM',
    categoryName: 'Victim of Disaster or Atrocity',
    description: 'Victims of mass disasters, ethnic violence, or flood/earthquake',
    displayOrder: 5,
  ),
  LegalAidCategory(
    id: 'f3595cfc-9d99-4e1f-89be-b0186267de66',
    categoryCode: 'GENERAL',
    categoryName: 'General – Annual income below ₹3 Lakh',
    description: 'Individuals with annual household income less than 3 Lakh Rupees',
    displayOrder: 6,
  ),
];
