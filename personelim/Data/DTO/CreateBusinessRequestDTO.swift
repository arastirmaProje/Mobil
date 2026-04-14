//
//  CreateBusinessRequestDTO.swift
//  personelim
//
//  Created by Tuğberk Acabey on 6.12.2025.
//

struct CreateBusinessRequestDTO: Encodable {
    let businessName: String
    let phoneNumber: String
    let provinceId: Int
    let districtId: Int? // Opsiyonel yaptık normalde değildi api'den sıfır döndüğü için böyle yaptım eğer iller geliyorsa şirket oluşturma ekranında bunu normale çek eğer gelmiyorsa hala hata var demektir db tarafında.
    let address: String
    let description: String?
    let offices: [OfficeLocationDTO]?
}
