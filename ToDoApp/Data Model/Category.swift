//
//  Category.swift
//  ToDoApp
//
//  Created by Adem Mergen on 28.11.2023.
//

import Foundation
import RealmSwift

class Category: Object { // "Object" sınıfından türetilmiştir. Object, Realm tarafından sağlanan temel sınıftır ve bu sınıfın alt sınıfları Realm veritabanına kaydedilebilir ve sorgulanabilir nesnelerdir.
    
    @objc dynamic var name: String = "" // "@objc dynamic" Realm için gereklidir.
    @objc dynamic var dateCreated: Date = Date() //"var dateCreated: Date = Date()" kısmı ise "dateCreated" adında bir değişkenin tanımlandığını ve varsayılan değerinin "Date()" ile şu anki tarih ve saat olduğunu gösterir. Bu özellik, bir Date türünde olup, sınıfın yaratılması sırasında varsayılan bir değerle başlar. Eğer bir Item sınıfının özelliği olarak kullanılıyorsa, her yeni öğe oluşturulduğunda dateCreated özelliği otomatik olarak o anki tarih ve saat değeriyle atanır.

    let items = List<Item>() //"List<Item>" türündedir. List, Realm tarafından sağlanan bir koleksiyon türüdür ve Item adlı sınıfın nesnelerini içerir. Bu, "Category" sınıfının bir ilişkisel özelliği olarak düşünülebilir; her kategori, bir dizi "Item" nesnesini içerir.

    //Bu sınıfın temel amacı, belirli bir kategoriyi temsil etmek ve bu kategoriye ait özellikleri (ad, renk) ve bu kategoriye ait öğeleri ("Item" sınıfından) içeren bir koleksiyonu tutmaktır.
}


