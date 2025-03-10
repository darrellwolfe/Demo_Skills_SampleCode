
import pandas as pd

# Data preparation
data = [
    {"Acronym": "AARO", "Meaning": "Association of Appraiser Regulatory Officials", "Description": "Allied Organization"},
    {"Acronym": "AAS", "Meaning": "Assessment Administration Specialist", "Description": "IAAO Professional Designation"},
    {"Acronym": "AI", "Meaning": "Appraisal Institute", "Description": "Allied Organization"},
    {"Acronym": "AIC", "Meaning": "Appraisal Institute of Canada", "Description": "Allied Organization"},
    {"Acronym": "AMC", "Meaning": "Associate Member Committee", "Description": "IAAO Committee"},
    {"Acronym": "APB", "Meaning": "Appraisal Practices Board", "Description": "TAF Sub Board"},
    {"Acronym": "APTC", "Meaning": "American Property Tax Counsel", "Description": "Allied Organization"},
    {"Acronym": "AQB", "Meaning": "Appraiser Qualifications Board", "Description": "TAF Sub Board"},
    {"Acronym": "ASA", "Meaning": "American Society of Appraisers", "Description": "Allied Organization"},
    {"Acronym": "ASB", "Meaning": "Appraisal Standards Board", "Description": "TAF Sub Board"},
    {"Acronym": "ASC", "Meaning": "Appraisal Subcommittee of the Federal Financial Institutions Examinations Council", "Description": "Federal Committee"},
    {"Acronym": "ASFMRA", "Meaning": "American Society of Farm Managers and Rural Appraisers", "Description": "Allied Organization"},
    {"Acronym": "AVM", "Meaning": "Automated Valuation Model", "Description": "Commonly Used Appraisal Term"},
    {"Acronym": "BOT", "Meaning": "Board of Trustees", "Description": "TAF Sub Board & Commonly Used Business Term"},
    {"Acronym": "C&S", "Meaning": "Councils and Sections", "Description": "IAAO Committee"},
    {"Acronym": "CAAS", "Meaning": "Computer Assisted Appraisal Section", "Description": "IAAO Subcommittee"},
    {"Acronym": "CAE", "Meaning": "Certified Assessment Evaluator", "Description": "IAAO Professional Designation"},
    {"Acronym": "CAMA", "Meaning": "Computer Assisted Mass Appraisal", "Description": "Commonly Used Appraisal Term"},
    {"Acronym": "CAP", "Meaning": "Course Approval Program", "Description": "TAF Sub Program"},
    {"Acronym": "CAPE", "Meaning": "Centre for Advanced Property Economics", "Description": "Allied Organization"},
    {"Acronym": "CAPS", "Meaning": "IAAO Chapters, Affiliates, Provincial/State Associations", "Description": "IAAO Term"},
    {"Acronym": "CCC", "Meaning": "Conference Content Committee", "Description": "IAAO Committee"},
    {"Acronym": "CEU", "Meaning": "Continuing Education Unit", "Description": "Commonly Used Business Term"},
    {"Acronym": "CLE", "Meaning": "Continuing Legal Education", "Description": "Commonly Used Business Term"},
    {"Acronym": "CMS", "Meaning": "Cadastral Mapping Specialist", "Description": "IAAO Professional Designation"},
    {"Acronym": "ECAFS", "Meaning": "Education Council for Appraisal Foundation Sponsors", "Description": "TAF Sub Board"},
    {"Acronym": "ESRI", "Meaning": "Environmental Systems Research Group, Inc.", "Description": "Private Company"},
    {"Acronym": "F&E", "Meaning": "Fair & Equitable Magazine", "Description": "IAAO Publication"},
    {"Acronym": "FDGC(SCD)", "Meaning": "Federal Geographic Data Committee (Subcommittee for Cadastral Data)", "Description": "Federal Committee & Allied Organization"},
    {"Acronym": "FECOVAL", "Meaning": "Federacion de Colegios de Valuadores, A. C. (Mexico)", "Description": "Allied Organization"},
    {"Acronym": "FIABCI", "Meaning": "Federation Internationale des Administrateurs de Biens Conseils et Agents Immobiliers or International Real Estate Federation (France)", "Description": "Allied Organization"},
    {"Acronym": "FIRREA", "Meaning": "Federal Institutions Reform, Recovery & Enforcement Act (of 1989)", "Description": "Federal Legislation"},
    {"Acronym": "FTA", "Meaning": "Federation of Tax Administrators", "Description": "Allied Organization"},
    {"Acronym": "GIS", "Meaning": "Geographic Information Systems", "Description": "Commonly Used Appraisal Term"},
    {"Acronym": "IAAO", "Meaning": "International Association of Assessing Officers", "Description": "IAAO Term"},
    {"Acronym": "IDECC", "Meaning": "International Distance Education Certification Center", "Description": "Certifying Organization"},
    {"Acronym": "IEW", "Meaning": "Instructor Evaluation Workshop", "Description": "IAAO Term"},
    {"Acronym": "iMIS", "Meaning": "Not an acronym-trademark name", "Description": "IAAO Membership Database"},
    {"Acronym": "IPT", "Meaning": "Institute for Professionals in Taxation", "Description": "Allied Organization"},
    {"Acronym": "IPTI", "Meaning": "International Property Tax Institute", "Description": "Allied Organization"},
    {"Acronym": "IRSC", "Meaning": "Instructor Relations Subcommittee", "Description": "IAAO Subcommittee"},
    {"Acronym": "IRRV", "Meaning": "Institute of Revenues, Rating and Valuation (United Kingdom)", "Description": "Allied Organization"},
    {"Acronym": "IRWA", "Meaning": "International Right of Way Association", "Description": "Allied Organization"},
    {"Acronym": "IVSC", "Meaning": "International Valuation Standards Council (United Kingdom)", "Description": "Allied Organization"},
    {"Acronym": "JPTAA", "Meaning": "Journal of Property Tax Assessment and Administration", "Description": "IAAO Publication"},
    {"Acronym": "KAB", "Meaning": "Korea Appraisal Board", "Description": "Allied Organization"},
    {"Acronym": "KAPA", "Meaning": "Korea Association of Property Appraisers", "Description": "Allied Organization"},
    {"Acronym": "LHC", "Meaning": "Local Host Committee", "Description": "IAAO Committee"},
    {"Acronym": "MARP", "Meaning": "Mass Appraisal of Real Property", "Description": "IAAO Publication"},
    {"Acronym": "MJC", "Meaning": "Metropolitan Jurisdiction Council", "Description": "IAAO Subcommittee"},
    {"Acronym": "MSC", "Meaning": "Membership Services Committee", "Description": "IAAO Committee"},
    {"Acronym": "NACAO", "Meaning": "North American Conference of Appraisal Organizations", "Description": "Allied Organization"},
    {"Acronym": "NACo", "Meaning": "National Association of Counties", "Description": "Allied Organization"},
    {"Acronym": "NAIFA", "Meaning": "National Association of Independent Fee Appraisers", "Description": "Allied Organization"},
    {"Acronym": "NCRAAO", "Meaning": "North Central Regional Association of Assessing Officers", "Description": "Allied Organization"},
    {"Acronym": "NGO", "Meaning": "Non Governmental Organization", "Description": "Commonly Used Business Term"},
    {"Acronym": "NRAAO", "Meaning": "Northeastern Regional Association of Assessing Officers", "Description": "Allied Organization"},
    {"Acronym": "ODF", "Meaning": "One Day Forum", "Description": "IAAO Term"},
    {"Acronym": "PAAA", "Meaning": "Property Appraisal Assessment Administration (red book)", "Description": "IAAO Publication"},
    {"Acronym": "PAV", "Meaning": "Property Assessment Valuation (green book)", "Description": "IAAO Publication"},
    {"Acronym": "PDA", "Meaning": "Professional Designation Advisor", "Description": "IAAO Term"},
    {"Acronym": "PDP", "Meaning": "Professional Designation Program", "Description": "IAAO Term"},
    {"Acronym": "PDSC", "Meaning": "Professional Designations Subcommittee", "Description": "IAAO Subcommittee"},
    {"Acronym": "PPS", "Meaning": "Personal Property Specialist", "Description": "IAAO Professional Designation"},
    {"Acronym": "PPS", "Meaning": "Personal Property Section", "Description": "IAAO Subcommittee"},
    {"Acronym": "PRIA", "Meaning": "Property Records Industry Association", "Description": "Allied Organization"},
    {"Acronym": "PTAPP", "Meaning": "Property Tax Assessment Policies and Practices Report (formerly Taxonomy)", "Description": "IAAO Publication"},
    {"Acronym": "PUS", "Meaning": "Public Utility Section", "Description": "IAAO Subcommittee"},
    {"Acronym": "RBA", "Meaning": "Russian Board of Appraisers", "Description": "Allied Organization"},
    {"Acronym": "Rep", "Meaning": "IAAO Representative", "Description": "IAAO Term"},
    {"Acronym": "RES", "Meaning": "Residential Evaluation Specialist", "Description": "IAAO Professional Designation"},
    {"Acronym": "RFP", "Meaning": "Request for Proposal", "Description": "Commonly Used Business Term"},
    {"Acronym": "RICS", "Meaning": "Royal Institution of Chartered Surveyors (United Kingdom)", "Description": "Allied Organization"},
    {"Acronym": "RSA", "Meaning": "Russian Society of Appraisers", "Description": "Allied Organization"},
    {"Acronym": "SIAA", "Meaning": "Self-Regulated Inter-regional Association of the Appraisers (Russia)", "Description": "Allied Organization"},
    {"Acronym": "SRM", "Meaning": "Student Reference Manual", "Description": "IAAO Course/Workshop/ODF Materials"},
    {"Acronym": "SUMA", "Meaning": "Suma Gestion Tributaria (Property Tax Entity in Alicante, Spain)", "Description": "Allied Organization"},
    {"Acronym": "TA", "Meaning": "Technical Assistance", "Description": "IAAO Term"},
    {"Acronym": "TAF", "Meaning": "The Appraisal Foundation", "Description": "Allied Organization"},
    {"Acronym": "ThaiAF", "Meaning": "Thai Appraisal Foundation", "Description": "Allied Organization"},
    {"Acronym": "TSC", "Meaning": "Technical Standards Committee", "Description": "IAAO Committee"},
    {"Acronym": "UBC", "Meaning": "University of British Columbia", "Description": "Allied Organization"},
    {"Acronym": "URISA", "Meaning": "Urban and Regional Information Systems Association", "Description": "Allied Organization"},
    {"Acronym": "USPAP", "Meaning": "Uniform Standards of Professional Appraisal Practices", "Description": "IAAO Committee & Commonly Used Appraisal Term for TAF-ASB Developed Standards for Appraisal in North America"},
    {"Acronym": "VOA", "Meaning": "Valuation Office Agency (United Kingdom)", "Description": "Allied Organization"},
    {"Acronym": "WAVO", "Meaning": "World Association of Valuation Organisations", "Description": "Allied Organization"},
    {"Acronym": "ZAIO", "Meaning": "Zone Appraisal and Imaging Operations", "Description": "Private Company"}
]

# Create DataFrame
df = pd.DataFrame(data)

# Write to Excel
df.to_excel("IAAO_acronyms.xlsx", index=False)

print("Data has been successfully written to IAAO_acronyms.xlsx")
