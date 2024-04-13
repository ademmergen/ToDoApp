//
//  CategoryTableViewController.swift
//  ToDoApp
//
//  Created by Adem Mergen on 28.11.2023.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    let realm = try! Realm() //Bu Swift kodu, bir "Realm" nesnesini oluşturmak için kullanılan bir ifadeyi temsil eder. "try!" ifadesi, bu satırın "zorunlu çözümleme" anlamına gelir. Yani, eğer bu satırda bir hata oluşursa (örneğin, Realm nesnesi oluşturulamazsa), uygulama çalışmasını durdurur.
    
    // Alternatif(Hatayı yakalamak için):
    
    /*
    do {
        let realm = try Realm()
        // Realm nesnesi başarıyla oluşturuldu, burada devam edilebilir.
    } catch {
        // Hata oluştu, hata işleme mantığı burada eklenir.
        print("Hata oluştu: \(error)")
    }
     */
    
    var categories: Results<Category>? //"Results" türü, Realm veritabanından yapılan sorguların sonuçlarını temsil eden bir türdür. Category ise bu sonuçların hangi türde olduğunu belirtir.
    //"?" Bu, değişkenin opsiyonel (optional) olduğunu belirtir. Yani, categories değişkeni Results<Category> türünden bir değer içerebilir veya içermeyebilir. Bu, özellikle Realm sorgularında her zaman bir sonuç dönmeyebileceği durumları ele almak için kullanılır. Bu "Results" nesnesi, Realm'den alınan canlı verilere otomatik olarak güncellenir, bu nedenle veritabanındaki değişikliklere anında tepki verebilir.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)) //Realm dosyasının konumunu konsola yazdırır.
        
        tableView.rowHeight = 80.0 // Satır yüksekliğini ayarladığımız kod.
        //tableView.separatorStyle = .none // Tableview cell'deki ayırma çizgilerini yok eder.
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //"?.count" Bu, opsiyonel zincirleme ifadeyi temsil eder. Eğer "categories" değeri nil ise, ifade nil olarak değerlendirilir ve count kısmına geçilmez. Eğer "categories" değeri nil değilse, count özelliği çağrılır ve bu özelliğin değeri alınır.
        
        //"?? 1" Bu, nil-coalescing operatörüdür. Eğer sol tarafındaki değer (categories?.count) nil ise, sağ tarafındaki değer olan 1 kullanılır. Yani, eğer "categories" değeri nil ise, fonksiyon 1 değerini döndürecektir.
        
        //Bu ifade, "categories" içindeki elemanların sayısını döndürür. Eğer "categories" nil ise (yani, bir hata oluştuğunda veya veritabanından hiç veri alınmamışsa), varsayılan olarak 1 değeri döndürülür. Bu, genellikle bir tablo görünümünde kullanılan hücre sayısını belirlemek için kullanılır, özellikle de veri alınamadığında veya hata durumlarında bir varsayılan değer kullanmak istendiğinde.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell // "as! SwipeTableViewCell" Bu kısım, "dequeueReusableCell" yöntemi tarafından döndürülen hücre örneğini bir tür olarak belirtir. Hücreyi "SwipeTableViewCell" türüne dönüştürmek istediğimizi belirtiyor. as! ifadesi, bu dönüşümün zorunlu olduğunu ve başarısız olması durumunda bir hata oluşturulması gerektiğini belirtir.
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet" // Eğer `categories` dizisi nil ise veya belirtilen index'te bir kategori yoksa, "No Categories added yet" yazısı gösterilir.
        cell.accessoryType = .disclosureIndicator // Sağa bakan ok.
        cell.delegate = self
        return cell
    }
    
    //Bu fonksiyon, bir tablo hücresi için kaydırma işlemlerini yapılandırmak ve düğmeler eklemek için kullanılır.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var actions = [SwipeAction]() //actions adında bir dizi oluşturulur. Bu dizi, sağa ve sola kaydırma işlemleri için eklenecek düğmeleri içerecektir.

        if orientation == .right { //Bu blok, hücreyi sağa kaydırmada görünecek olan "Delete" (Sil) butonunu oluşturur.
            // Sağa doğru kaydırma işlemi için "Delete" butonu
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in //"deleteAction" adında bir "SwipeAction" örneği oluşturulur. Stil olarak ".destructive" kullanılır, bu genellikle silme işlemini temsil eder.
                self.updateModel(at: indexPath) //Düğme üzerine tıklanınca self.updateModel(at: indexPath) çağrılır. Bu, belirli bir hücrenin modelini güncellemek için bir fonksiyon çağrısıdır.
            }
            deleteAction.image = UIImage(systemName: "xmark.bin.fill") //UIImage(systemName: "xmark.bin.fill") ifadesi, SF Symbols sisteminden bir sembolle oluşturulmuş bir UIImage örneği döndürür. SF Symbols, Apple'ın iOS ve diğer platformlarda kullanılan sembol setidir. "xmark.bin.fill" sembolü, bir çöp kutusunu veya bir öğenin silinmesini temsil eden genel bir semboldür.
            actions.append(deleteAction) // Oluşturulan deleteAction düğmesi actions dizisine eklenir.
        }

        if orientation == .right {
            // Sağa doğru kaydırma işlemi için "Edit" butonu
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in //editAction adında bir SwipeAction örneği oluşturulur. Stil olarak .default kullanılır, bu genellikle standart bir işlemi temsil eder.
                self.showEditAlert(at: indexPath) //Düğme üzerine tıklanınca self.showEditAlert(at: indexPath) çağrılır. Bu, belirli bir hücre için düzenleme için bir uyarı gösteren bir fonksiyon çağrısıdır.
            }
            editAction.image = UIImage(systemName: "square.and.pencil")
            editAction.backgroundColor = .systemBlue
            actions.append(editAction) //Oluşturulan editAction düğmesi actions dizisine eklenir.
        }

        return actions //Fonksiyon son olarak oluşturulan düğmeleri içeren actions dizisini döndürür. Bu, sağa veya sola kaydırma işlemi sırasında görünecek olan düğmelerin belirlenmesini sağlar.
    }

    func showEditAlert(at indexPath: IndexPath) {
        let categoryToEdit = categories?[indexPath.row] //categories dizisinden belirli bir indexPath'teki kategori bilgisini alır. Bu, düzenleme işlemi için seçilen kategorinin bilgisini içeren bir Category nesnesini temsil eder.

        let alert = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert) //Bir UIAlertController oluşturulur. Başlık "Edit Category" olarak ayarlanır ve stil olarak .alert kullanılır. Bu, kullanıcıya bir uyarı göstermek için kullanılan bir kontrolör türüdür.

        alert.addTextField { textField in //UIAlertController'a bir metin alanı (UITextField) eklenir. Bu metin alanı, kullanıcının kategori adını düzenlemesine izin verir. Ayrıca, mevcut kategori adı bu metin alanına varsayılan olarak eklenir.
            textField.text = categoryToEdit?.name
        }
        //"Save" adlı bir UIAlertAction oluşturulur. Bu, kullanıcının düzenleme yaptıktan sonra kategori bilgisini kaydetmesini sağlar.Bir kapanış (closure) içinde, yeni kategori adını kontrol eder. Eğer yeni ad boş değilse, updateCategory fonksiyonunu çağırarak kategori bilgisini günceller. Aksi takdirde, bir uyarı mesajı yazdırır.
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let newName = alert.textFields?.first?.text {
                if !newName.isEmpty { //Eğer newName adlı metin boş değilse (yani, içinde en az bir karakter varsa), ifade true olur ve if bloğu çalışır. Eğer newName boş ise (yani, içinde hiç karakter yoksa), ifade false olur ve if bloğu çalışmaz, else bloğuna geçer.
                    self?.updateCategory(category: categoryToEdit, newName: newName)
                } else {
                    // Kullanıcı yeni bir isim girmeden "Save" butonuna bastı, burada bir uyarı verebiliriz.
                    print("Warning: Please enter a new category name.")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) //"Cancel" adlı bir UIAlertAction oluşturulur. Bu, kullanıcının düzenleme işleminden vazgeçmesini sağlar.
        
        //Oluşturulan "Save" ve "Cancel" eylemleri, UIAlertController'a eklenir.
        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil) //Oluşturulan UIAlertController'ı ekranda gösterir. Bu, kullanıcıya kategori adını düzenleme fırsatı tanır.
    }
    
    func updateCategory(category: Category?, newName: String) { //Fonksiyon, category adında bir Category opsiyonel (optional) türde bir parametre ve newName adında bir String parametre alır. "Category?" türündeki parametre opsiyonel olduğu için, nil olabilir veya bir Category nesnesini temsil edebilir.
        
        // category değişkeni nil değilse işlemleri gerçekleştir
        if let existingCategory = category { //Bu ifade, category değişkeninin nil olup olmadığını kontrol eder. Eğer nil değilse, if bloğu içindeki işlemler gerçekleştirilir. Nil değilse, else bloğuna geçilir.
            do {
                // Realm yazma işlemine başla
                try realm.write {
                    // Kategori adını güncelle
                    existingCategory.name = newName
                }

                // Yazma işlemi başarıyla tamamlandı, kullanıcıya mesaj ver
                print("Category updated successfully")

                // Verileri tekrar yükle
                loadCategories()
            } catch {
                // Yazma işlemi sırasında hata oluştuğunda konsola yazdır
                print("Error updating category: \(error)")
            }
        } else {
            // Eğer category nil ise, işlemi gerçekleştirme ve kullanıcıyı bilgilendirme
            print("Error: Attempted to update a non-existing category.")
        }
    }

    //Bu fonksiyon, kullanıcının bir hücreyi kaydırdığında hangi seçeneklerin uygulanacağını belirlemek için kullanılır.
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions { //orientation: Kaydırma işleminin yönü. Bu, .right veya .left olabilir.
        var options = SwipeOptions() //türünde bir nesne oluşturuluyor. Bu nesne, kaydırma işlemlerinin davranışını ve görünümünü özelleştirmek için kullanılır.
        options.expansionStyle = .destructive //Bu satır, kaydırma işleminin genişleme stiline ilişkin bir özelliği belirler. .destructive değeri, kaydırma işlemi tamamlandığında hücrenin yıkıcı bir şekilde genişleyeceğini belirtir. Yani, hücrenin kaydırılması sonucu gerçekleşen eylem yıkıcı (örneğin, bir öğenin silinmesi) ise hücre genişleyerek kullanıcıya bu durumu belirtir.
        return options //Hazırlanan SwipeOptions nesnesi fonksiyon tarafından döndürülür ve bu, kaydırma işleminin seçeneklerini belirlemek üzere kullanılır.
    }

    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //Bu kod bloğu genellikle, bir hücreye tıklanarak gerçekleşen segue geçişinde, hedef sayfaya gitmeden önce gerekli verilerin iletilmesi için kullanılır.
        let destinationVC = segue.destination as! ItemTableViewController //Bu satır, segue'nin hedef view controller'ını belirler. segue.destination ile alınan değer, UIViewController tipindedir, ancak burada bu değeri ItemTableViewController tipine dönüştürüyoruz (as! ItemTableViewController). Bu dönüşümün güvenli olduğunu varsayıyoruz, çünkü bu segue'nin hedefi olarak ItemTableViewController belirlenmiş.
        if let indexPath = tableView.indexPathForSelectedRow { //Bu satır, kullanıcının hangi hücreyi seçtiğini kontrol eder. Eğer kullanıcı bir hücre seçmişse, indexPath değişkeni bu seçilen hücrenin index path'ini içerir.
            destinationVC.selectedCategory = categories?[indexPath.row] //Bu satırda, ItemTableViewController'ın selectedCategory özelliğine değer atanır. Bu değer, kullanıcının seçtiği kategorinin olduğu categories dizisinden alınır. Ancak, güvenlik amacıyla opsiyonel bağlantılar (optional chaining) kullanılır. Eğer categories dizisi varsa ve seçilen hücrenin index path'i geçerliyse, ilgili kategori atanır; aksi halde nil atanır.
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) { //Bu fonksiyon, bir UIBarButtonItem olan "Add" butonuna basıldığında çağrılır.
        var textField = UITextField() // Bir UITextField türünden değişken tanımlanır. Bu değişken, UIAlertController içindeki metin alanına erişim sağlamak için kullanılır.
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert) //UIAlertController oluşturulur. Başlık "New Category" olarak ayarlanır ve preferredStyle ".alert" olarak belirlenir.
        let addAction = UIAlertAction(title: "Add", style: .default) {(action) in //UIAlertAction oluşturulur. Eğer kullanıcı "Add" butonuna basarsa, bu kısım içinde bir kapanış (closure) çağrılır. Bu kapanış içinde yeni bir Category nesnesi oluşturulur, bu nesneye kullanıcının girdiği isim atanır (textField.text), ve ardından bu kategori save fonksiyonu kullanılarak Realm veritabanına eklenir.
            let newCategory = Category()
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // UIAlertAction oluşturulur. Eğer kullanıcı "Cancel" butonuna basarsa, herhangi bir işlem yapılmaz.
        alert.addAction(addAction) // Oluşturulan UIAlertAction nesneleri UIAlertController'a eklenir.
        alert.addAction(cancelAction)
        alert.addTextField {(field) in //UIAlertController'a bir metin alanı (UITextField) eklenir. Bu alan, kullanıcının yeni kategori ismini girmesi için kullanılır. Ayrıca, bu metin alanına bir yer tutucu (placeholder) eklenir.
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil) //UIAlertController, kullanıcıya gösterilmek üzere ekrana sunulur.
    }
    
    //MARK: - Data Manipulation Methods
    func save(category: Category) { //Bu fonksiyon, "Category" tipinde bir parametre alır ve bu kategoriyi "Realm" veritabanına ekler.
        do {
            try realm.write { // "realm.write" bloğu, Realm veritabanında bir yazma işlemi gerçekleştirmek için kullanılır. Bu blok içinde, veritabanına bir kategori eklemek amacıyla "realm.add(category)" ifadesi kullanılır. "try" anahtar kelimesi ile çevrelenmiş bir blok içinde olduğu için, bir hata olması durumunda "catch" bloğu çalışır ve hatayı yazdırır.
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData() // Veritabanına yeni bir kategori ekledikten sonra, UITableView'yi güncellemek amacıyla "reloadData()" fonksiyonu çağrılır. Bu, tablonun içeriğini güncellemek ve yeni eklenen kategoriyi göstermek için kullanılır.
    }
    
    func loadCategories() { //Bu fonksiyon, kategorileri yüklemek ve "categories" adlı bir diziye atmak amacıyla kullanılır.
        categories = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: false)
        //categories = realm.objects(Category.self) // "realm.objects(Category.self)" ifadesi, "Realm" veritabanındaki "Category" sınıfına ait tüm nesneleri çeker. Bu nesneler, "categories" adlı bir değişkene atanır. "categories" genellikle sınıfın özellikleri arasında tanımlanmıştır ve UITableView'yi güncellemek amacıyla kullanılır.
        tableView.reloadData() // Veritabanından kategoriler çekildikten sonra, UITableView'yi güncellemek amacıyla "reloadData()" fonksiyonu çağrılır. Bu, tablonun içeriğini güncellemek ve yeni kategorileri göstermek için kullanılır.
    }
    
    func updateModel(at indexPath: IndexPath) { //Bu kod bloğu, bir kategoriyi ve o kategoriye ait tüm öğeleri Realm veritabanından silmek için kullanılır. İşte kodun adım adım açıklaması:
        if let categoryForDeletion = self.categories?[indexPath.row] { //Bu satır, silinecek kategoriyi almak için bir güvenli bağlantı yapar. Eğer belirtilen indekste bir kategori mevcut değilse (nil ise), bu adımları atlamak için if bloğunun içine girilmez.
            do {
                try self.realm.write { //Bu satır, Realm veritabanına yazma işlemi başlatır. Realm'da veri değişikliklerini yapabilmek için bir yazma işlemi başlatmak önemlidir.
                    // Önce kategoriye ait tüm öğeleri sil
                    self.realm.delete(categoryForDeletion.items) //Bu satır, seçilen kategoriye ait tüm öğeleri siler. categoryForDeletion.items ifadesi, kategorinin items ilişki özelliğine erişir ve bu kategoriye ait olan tüm öğeleri temsil eder.
                    
                    // Sonra kategoriyi sil
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category and its items, \(error)")
            }
        }
    }
}

