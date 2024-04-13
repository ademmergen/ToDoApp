//
//  Item.swift
//  ToDoApp
//
//  Created by Adem Mergen on 28.11.2023.
//

import Foundation
import RealmSwift
class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()

    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // "LinkingObjects" türünde bir özelliktir. Bu, "Category" sınıfındaki "items" özelliğine bağlı olan "Item" nesnelerini temsil eder.
    //"fromType" parametresi, ilişkilendirilen nesnelerin türünü (Category.self) belirtir.
    //"property" parametresi, bu nesnelerin hangi özelliğe (items) bağlı olduğunu belirtir.
    
   //Bu sınıfın temel amacı, bir öğeyi temsil etmek ve bu öğenin başlığı, tamamlanma durumu, oluşturulma tarihi ve hangi kategoriye ait olduğu gibi özellikleri içermektir. parentCategory özelliği, bu öğenin hangi kategoriye ait olduğunu belirtir ve bu kategorideki items özelliği ile ilişkilidir.
}
