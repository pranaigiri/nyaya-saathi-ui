import '../../models/document_master.dart';

const List<DocumentMaster> localDocumentTypes = [
  DocumentMaster(
    id: '2d30eaa3-ae5c-419c-9962-e13ad6a9333e',
    documentCode: 'IDENTIFICATION_DOCUMENT',
    documentName: 'Identification Document (Voter, Aadhar)',
    description: 'A government-approved identification document',
    isActive: true,
  ),
  DocumentMaster(
    id: '05cffb0c-2ae7-469f-918c-9208720dd9d9',
    documentCode: 'INCOME_CERTIFICATE',
    documentName: 'Income Certificate',
    description: 'Government issued annual income certificate',
    isActive: true,
  ),
  DocumentMaster(
    id: 'a899b9db-3898-4a99-ad7c-ebe8ab9eecc8',
    documentCode: 'CASTE_CERTIFICATE',
    documentName: 'Caste Certificate',
    description: 'SC/ST community status certificate',
    isActive: true,
  ),
  DocumentMaster(
    id: '8b5e97fc-8f41-4562-bec4-01f4482f442f',
    documentCode: 'DISABILITY_CERTIFICATE',
    documentName: 'Disability Certificate',
    description: 'Medical certificate of disability',
    isActive: true,
  ),
  DocumentMaster(
    id: '877e46ba-089c-4ce0-953a-43fdd4ad2ed7',
    documentCode: 'DEATH_CERTIFICATE',
    documentName: 'Death Certificate',
    description: 'Official death registration certificate',
    isActive: true,
  ),
  DocumentMaster(
    id: 'c5a99b97-54e5-4dcb-b85e-ba76b57cda37',
    documentCode: 'POLICE_FIR',
    documentName: 'Police FIR',
    description: 'Copy of police FIR or complaint',
    isActive: true,
  ),
  DocumentMaster(
    id: '3c9f29b2-79fb-4914-a3d5-d325b1c3b03e',
    documentCode: 'AGE_PROOF_DOCUMENT',
    documentName: 'Birth/School Certificate',
    description: 'Official birth registration certificate or school certificate',
    isActive: true,
  ),
];
