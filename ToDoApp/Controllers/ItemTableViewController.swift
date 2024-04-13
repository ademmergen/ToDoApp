//
//  ItemTableViewController.swift
//  ToDoApp
//
//  Created by Adem Mergen on 28.11.2023.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ItemTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
   
    var selectedCategory : Category? {
        //"selectedCategory" değişkeninin değeri değiştiğinde, bu değişikliğe tepki göstermek veya bir işlem yapmak isteniyor olabilir.
        //Bu tür bir yapı, Swift dilinde "property observer" olarak bilinir. didSet bloğu, bu değişkenin değeri değiştiğinde otomatik olarak çağrılır.
        //"loadItems()" fonksiyonu, selectedCategory değişkeninin değerine bağlı olarak ilgili kategorideki öğeleri yüklemek için kullanılıyor olabilir. Yani, seçilen kategori değiştikçe ilgili öğeleri yüklemek amacıyla bu fonksiyon çağrılır.
        didSet {
            loadItems()
        }
    }
    
    let realm = try! Realm() //Bu kod satırı, Realm adlı bir veritabanı yönetim sistemi ile çalışan bir uygulamada kullanılır. let realm = try! Realm() ifadesi, bir Realm nesnesi oluşturmayı amaçlar.
    var toDoItems: Results<Item>? //Bu satır "toDoItems" adında bir değişken tanımlar ve bu değişken, bir Realm veritabanı sorgusunun sonuçlarını temsil eden bir Results türündedir ve bu sonuçlar Item adlı bir veri modeline aittir. Değişkenin nil olabileceği belirtilmiştir, yani bu yapıya ait bir değer olmayabilir.
    
    
    override func viewDidLoad() { //"viewDidLoad" fonksiyonu, view controller'ın yaşam döngüsündeki birinci aşama olduğu için genellikle bir view controller oluşturulduğunda ilk çağrılan metod olarak düşünülür. Bu nedenle, view controller'ın başlangıç durumlarını ve ayarlamalarını gerçekleştirmek için ideal bir noktadır.
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0 //Bu table view'in satır (cell) yüksekliğini 80.0 olarak ayarlar
        
    }
    
    override func viewWillAppear(_ animated: Bool) { //İlgili kod bloğu viewWillAppear içinde kullanılmış, çünkü sayfa görüntülendiğinde sayfanın başlığını güncellemek istiyoruz. Eğer bu işlem viewDidLoad içinde yapılırsa, sayfa yüklenirken bir kez yapılır ve daha sonra kullanıcı başka bir kategori seçtiğinde veya sayfayı kapattığında tekrar gerçekleşmez. viewWillAppear ise sayfa her görüntülendiğinde çalıştığı için, seçili kategori değiştiğinde başlığı güncellemek için daha uygun bir yerdir.
        //Bu kod bloğu, bir UIViewController sınıfında bulunan viewWillAppear(_:) metodunu override ederek, view controller'ın view'inin ekranda görünmeye başlamadan önce yapılacak işlemleri tanımlar.
        
        //super.viewWillAppear(animated)
        //loadItems()
        title = selectedCategory?.name
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1 //Bu kod bloğu, tablonun belirli bir bölümündeki satır sayısını belirlemek için kullanılır. Eğer toDoItems içinde öğeler varsa, o öğelerin sayısı kullanılır; eğer toDoItems nil veya boşsa, minimum olarak 1 satır gösterilir.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell //Bu satır, tablo hücresini (cell) geri döndürmek için dequeueReusableCell(withIdentifier:for:) metodunu kullanır. withIdentifier parametresi, kullanılacak hücrenin tanımlayıcıdır ve storyboard veya xib dosyasında bu tanımlayıcı ile belirtilmiş bir hücre kullanılır. as! SwipeTableViewCell ifadesi, hücrenin tipini belirtir ve bu hücrenin SwipeTableViewCell sınıfından türemiş olduğunu garanti eder.
        
        if let item = toDoItems?[indexPath.row] { //Bu satır, toDoItems içinde belirli bir indeksteki öğeyi almak için güvenli bir şekilde opsiyonel bağlama (optional binding) yapar. Eğer toDoItems nil değilse ve belirli bir indekste bir öğe varsa, bu blok içine girilir.
            let attributedString = NSMutableAttributedString(string: item.title) //Bu satır, öğenin başlığını içeren bir NSMutableAttributedString oluşturur. Bu, hücre içindeki metne özel biçimlendirmeler eklemek için kullanılır.
            
            if item.done { //Bu kontrol yapısı, eğer öğe tamamlanmışsa (item.done true ise) ve tamamlanmışsa ne tür biçimlendirmelerin uygulanacağını belirler. Eğer tamamlanmışsa, metnin üzerine çizgi eklenir ve rengi değiştirilir; ayrıca, bir onay işareti eklenir (cell.accessoryType = .checkmark). Eğer tamamlanmamışsa, çizgi kaldırılır ve renk eski haline getirilir (cell.accessoryType = .none).
                cell.accessoryType = .checkmark
                cell.tintColor = .systemBlue
                let attributes: [NSAttributedString.Key: Any] = [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.red
                ]
                attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
            } else {
                cell.accessoryType = .none
                attributedString.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: attributedString.length))
                attributedString.removeAttribute(.strikethroughColor, range: NSRange(location: 0, length: attributedString.length))
            }
            
            cell.textLabel?.numberOfLines = 0 //Bu satır, hücre içindeki metnin kaç satıra yayılacağını belirler. 0 değeri, metnin kaç satır olursa olsun tüm satırlara yayılmasını sağlar.
            cell.textLabel?.lineBreakMode = .byWordWrapping //Bu satır, metnin hücre sınırlarını aştığında kelime sırasına göre yeni satırlara geçmesini sağlar.
            cell.textLabel?.attributedText = attributedString //Bu satır, özel biçimlendirilmiş metni hücrenin metin etiketine (textLabel) atar.
        }
        cell.delegate = self //Bu satır, hücrenin swipe (sürükleme) işlemlerini dinleyecek olan SwipeTableViewCellDelegate protokolünü uygulayan bir nesnenin (muhtemelen self, yani bu view controller) belirlenmesini sağlar.
        return cell //Bu satır, oluşturulan ve ayarlanan hücreyi geri döndürür ve tabloda görüntülenmesini sağlar.
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var actions = [SwipeAction]() //Bu satır, SwipeAction tipindeki özel aksiyonların bir dizisini tanımlar. Bu dizi, belirli bir tablo hücresi için sağa veya sola kaydırma işlemlerine karşılık gelen aksiyonları içerecektir.
        
        if orientation == .right { //Bu kontrol yapısı, kaydırma yönlendirmesinin sağa (orientation == .right) olup olmadığını kontrol eder.
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.updateModel(at: indexPath) //Eğer sağa kaydırma yapılıyorsa, SwipeAction tipinde bir "Delete" aksiyonu oluşturulur. Bu aksiyon, .destructive stilde bir uyarı rengi ve "Delete" başlığına sahiptir. Aksiyon gerçekleştirildiğinde çağrılacak kapanma (closure) bloğu içinde, self.updateModel(at: indexPath) metodunu çağırarak modeldeki veriyi günceller. deleteAction'ın görüntüsü "xmark.bin.fill" simgesidir.
            }
            deleteAction.image = UIImage(systemName: "xmark.bin.fill")
            actions.append(deleteAction) //Oluşturulan "Delete" aksiyonu, actions dizisine eklenir.
        }
        
        if orientation == .right { //Bu ikinci kontrol yapısı da sağa kaydırma işlemi için kontrol edilir (muhtemelen bir hata, burada sola kaydırma için kontrol yapısı olması gerekebilir).
            
            let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
                self.showEditAlert(at: indexPath) //Eğer sağa kaydırma yapılıyorsa, SwipeAction tipinde bir "Edit" aksiyonu oluşturulur. Bu aksiyon, .default stilde bir varsayılan renge ve "Edit" başlığına sahiptir. Aksiyon gerçekleştirildiğinde çağrılacak kapanma (closure) bloğu içinde, self.showEditAlert(at: indexPath) metodunu çağırarak düzenleme için bir uyarı gösterir. editAction'ın görüntüsü "square.and.pencil" simgesidir ve arka plan rengi .systemBlue olarak ayarlanır.
               //actions.append(editAction): Oluşturulan "Edit" aksiyonu, actions dizisine eklenir.
            }
            editAction.image = UIImage(systemName: "square.and.pencil")
            editAction.backgroundColor = .systemBlue
            actions.append(editAction)
        }
        
        return actions //Bu satır, oluşturulan ve konfigüre edilen aksiyonları içeren actions dizisini geri döndürür. Bu, tablo hücresinin sağa veya sola kaydırılması durumunda görüntülenecek aksiyonları belirler.
    }
    
    func showEditAlert(at indexPath: IndexPath) {
        let itemToEdit = toDoItems?[indexPath.row] //Bu satır, düzenleme yapılacak olan öğeyi belirler. toDoItems içindeki belirli bir indeksteki öğeyi itemToEdit adlı bir değişkende saklar.
        
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert) //Bu satır, bir UIAlertController oluşturur. Başlık olarak "Edit Item" kullanılır ve stil olarak .alert belirlenir.
        
        alert.addTextField { textField in //Bu satır, UIAlertController'a bir metin alanı (UITextField) ekler. Bu metin alanının içeriği, itemToEdit'in başlığıyla doldurulur. Kullanıcı bu metin alanında öğeyi düzenleyebilir.
            textField.text = itemToEdit?.title
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in //Bu satır, "Save" adında bir UIAlertAction oluşturur. Bu aksiyonun stilini .default olarak belirler ve gerçekleştiğinde çağrılacak kapanma (closure) bloğu içinde öğenin güncellenmesi işlemini gerçekleştirir. [weak self] ifadesi, güçlü referans döngülerini önlemek için kullanılır.
            if let newName = alert.textFields?.first?.text { //Bu kontrol yapısı, UIAlertController'da bulunan metin alanından kullanıcının girdiği yeni adı alır. Eğer kullanıcı bir ad girdiyse, bu bloğa girilir.
                if !newName.isEmpty {//Yeni ad ile birlikte, öğenin güncellenmesi için updateItem metodunu çağırır. Bu metod, öğenin adını günceller.
                    self?.updateItem(item: itemToEdit, newName: newName)
                } else {
                    print("Warning: Please enter a new item name.") //Eğer kullanıcı boş bir ad girmişse, bir uyarı yazısı ekrana yazdırır.
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) //Bu satır, "Cancel" adında bir UIAlertAction oluşturur. Bu aksiyonun stilini .cancel olarak belirler ve gerçekleştiğinde herhangi bir işlem yapmaz.
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction) //Bu iki satır, oluşturulan aksiyonları UIAlertController'a ekler. "Save" aksiyonu "Cancel" aksiyonundan önce eklenir, bu nedenle sıralama ekranda da aynı sırayla görünecektir.
        
        present(alert, animated: true, completion: nil) //Bu satır, oluşturulan UIAlertController'ı ekranda gösterir. animated: true ifadesi, uyarının animasyonlu bir şekilde ekranda belirmesini sağlar. completion: nil ifadesi, uyarı gösterildikten sonra herhangi bir tamamlama bloğunu belirtmez.
    }
    
    func updateItem(item: Item?, newName: String) { //Bu metodun başlangıcı. Bir Item öğesini ve yeni adını alır.
        //Bu metodun temel amacı, gelen item'ı güncelleyerek veritabanını ve ekrandaki görüntüyü güncellemektir. Eğer item nil ise, bu durumda bir hata mesajı yazdırılır çünkü nil bir öğeyi güncellemeye çalışmak hatalı bir durumdur.
        if let existingItem = item { //Bu kontrol yapısı, gelen item'ın nil olup olmadığını kontrol eder. Eğer item nil değilse, bu bloğa girilir.
            do {
                try realm.write {
                    existingItem.title = newName //Bu satır, realm üzerinde yazma işlemi başlatır. existingItem.title = newName ifadesi, existingItem'ın başlığını (title özelliğini) newName ile günceller.
                }
                
                print("Item updated successfully")
                
                loadItems()
            } catch { //bloğundaki herhangi bir hata durumunda bu catch bloğu çalışır. Hata mesajı, konsola yazdırılır.
                
                print("Error updating item: \(error)")
            }
        } else {
            
            print("Error: Attempted to update a non-existing item.") //Eğer gelen item nil ise (yani güncellenmek istenen öğe mevcut değilse), bu bloğa girilir. Bu durumda, konsola "Error: Attempted to update a non-existing item." şeklinde bir mesaj yazdırılır.
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions() //Bu satır, SwipeOptions tipinde bir nesne olan options'ı oluşturur. Bu nesne, kaydırma işlemi için çeşitli seçenekleri içerecektir.
        options.expansionStyle = .destructive //Bu satır, options nesnesinin expansionStyle özelliğini .destructive olarak ayarlar. Bu, kaydırma işlemi tamamlandığında bir genişleme efekti uygulanacak ve bu efekt, genellikle yıkıcı (destructive) bir tarzda olacaktır. Yani, kaydırma işlemi genellikle bir öğenin silinmesini temsil eder.
        return options //Bu satır, belirlenen seçenekleri içeren options nesnesini geri döndürür. Bu seçenekler, belirli bir tablo hücresinin sağa veya sola kaydırılması durumunda uygulanacak efektleri ve davranışları belirler.
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//Bu metod, kullanıcının bir tablo hücresine dokunduğunda (seçtiğinde) çağrılır. Bu metod, belirli bir hücre seçildiğinde ne tür eylemlerin gerçekleştirileceğini belirler.
        tableView.deselectRow(at: indexPath, animated: false) //Bu satır, seçilen hücrenin seçim durumunu kaldırır. Eğer bu satır olmasaydı, hücre seçili kalmaya devam ederdi. animated parametresi, seçim durumunun kaldırılması sırasında animasyonun olup olmamasını kontrol eder.
        
        if let item = toDoItems?[indexPath.row] { //Bu kontrol yapısı, toDoItems dizisinden belirli bir indeksteki öğenin alınmasını ve bu öğenin nil olup olmadığının kontrolünü yapar.
            try! realm.write {
                item.done = !item.done //Bu satır, realm veritabanında bir yazma işlemi başlatır. İlgili öğenin done özelliğini tersine çevirir, yani tamamlandıysa tamamlanmamış, tamamlanmamışsa tamamlanmış yapar. try! ifadesi, bu işlemi zorlaştırır ve hata durumlarında uygulamanın çökmesine neden olabilir. Daha iyi bir uygulama yapısı için hata kontrolü yapılması önerilir.
            }
            
            // Önce yeni durumu yükleyin
            loadItems() //Bu satır, loadItems metodunu çağırarak güncel verileri yükler. Bu, veritabanındaki değişikliklerin yansıtılmasını ve tablonun güncellenmesini sağlar.
            
            // Şimdi taşıma işlemini gerçekleştirin
            tableView.beginUpdates()
            
            // Results koleksiyonunu Array'e dönüştürün ve indeksi bulun
            if let updatedIndex = toDoItems?.index(of: item) { //Bu satır, güncellenen öğenin yeni indeksini bulmaya çalışır. toDoItems dizisi bir Results türü olduğundan, index(of:) metodunu kullanarak öğenin indeksini bulmaya çalışır. Ancak, bu metodun opsiyonel bir değer döndürdüğü unutulmamalıdır, bu nedenle if let kontrolü kullanılır.
                let targetIndexPath = IndexPath(row: updatedIndex, section: indexPath.section) //Eğer yeni indeks bulunursa, bu indeksi kullanarak yeni hedef `IndexPath` oluşturulur. Bu, seçilen hücrenin taşınacağı hedef konumu temsil eder.
                tableView.moveRow(at: indexPath, to: targetIndexPath) //Bu satır, seçilen hücrenin mevcut indeksinden (`indexPath`) yeni hedef indeksine (`targetIndexPath`) taşınmasını sağlar. Bu, hücrenin görsel konumunu değiştirir, ancak veri modelindeki sıralama düzenini değiştirmez.
            }
            
            tableView.endUpdates() //Bu satır, tablo görünümündeki güncellemelerin bittiğini belirtir. Bu, tablonun güncellenmesi ve animasyonların uygulanması için önemlidir.
        }
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {//Bu fonksiyon, bir UIBarButton'a bağlı olarak çalışan bir IBAction'dır. Kullanıcı bu butona tıkladığında çağrılır.
        
        var textField = UITextField() //Bu satır, UIAlertController içinde kullanılacak bir UITextField öğesini tanımlar.
        
        let alert = UIAlertController(title: "New Item", message: "", preferredStyle: .alert)//Bu satır, bir UIAlertController oluşturur. Başlık olarak "New Item" kullanılır ve stil olarak .alert belirlenir.
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in //Bu satır, "Add Item" adında bir UIAlertAction oluşturur. Bu aksiyonun stilini .default olarak belirler ve gerçekleştiğinde çağrılacak kapanma (closure) bloğu içinde yeni bir öğe oluşturulmasını ve veritabanına eklenmesini sağlar.
            
            if let currentCategory = self.selectedCategory { //Bu kontrol yapısı, selectedCategory özelliğinin nil olup olmadığını kontrol eder. Eğer nil değilse, bu bloğa girilir.
                do {
                    try self.realm.write {//Bu satır, veritabanına yazma işlemi başlatır. Yeni bir `Item` öğesi oluşturulur, kullanıcının girdiği metinle (`textField.text!`) başlığı doldurulur, oluşturulma tarihi atanır ve bu öğe, seçilen kategoriye (`currentCategory.items`) eklenir.
                        
                        
                        //Bu kod bloğu, kullanıcının girdiği metni ve bir tarih bilgisini kullanarak yeni bir Item öğesi oluşturur ve bu öğeyi seçilen kategoriye ekler.
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date() //Bu özellik, öğenin oluşturulma tarihini temsil eder ve şu anki tarih ve saat değeri (Date() ifadesi) ile doldurulur.
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData() //Bu satır, tabloyu günceller. Eklenen yeni öğe, tabloya yansıtılarak gösterilir.
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) //Bu satır, "Cancel" adında bir UIAlertAction oluşturur. Bu aksiyonun stilini .cancel olarak belirler, yani bu buton, genellikle kullanıcı işlemi iptal etmek istediğinde kullanılır. handler: nil ifadesi, bu butona tıklandığında herhangi bir özel işlem yapılmasını sağlamaz.
        
        alert.addTextField { (alertTextfield) in //Bu satır, UIAlertController'a bir metin alanı (UITextField) ekler. Eklenen metin alanının özelliklerini belirlemek için bir closure (kapanma bloğu) kullanır.
            alertTextfield.placeholder = "Create a new item" //Bu satır, metin alanına bir yer tutucu (placeholder) metni ekler. Bu metin, kullanıcının giriş yapması gereken açıklama veya talimatı temsil eder.
            textField = alertTextfield //Bu satır, bir önceki bölümde tanımlanan textField değişkenine, UIAlertController'a eklenen metin alanının referansını atar. Bu sayede, kullanıcının girdiği metni daha sonra kullanabiliriz.
        }
        
        alert.addAction(action) //Bu satırlar, oluşturulan iki UIAlertAction'ı (Add Item ve Cancel) UIAlertController'a ekler. addAction metodu ile her aksiyon, UIAlertControllers'ın altında bir düğme olarak görüntülenecektir. Eklenen aksiyonların sırası, ekranda görünen sırayı belirler.
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil) //Bu satır, oluşturulan UIAlertController'ı ekranda gösterir. animated: true ifadesi, uyarının animasyonlu bir şekilde ekranda belirmesini sağlar. completion: nil ifadesi, uyarı gösterildikten sonra herhangi bir tamamlama bloğunu belirtmez.
        
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(item: Item) { //Bu fonksiyon, bir Item öğesini veritabanına eklemek için kullanılır. Fonksiyon bir Item öğesini parametre olarak alır ve bu öğeyi veritabanına ekler.
        do {
            try realm.write { //Bu satır, Realm veritabanında bir yazma işlemi başlatır. realm.write bloğu içinde yer alan işlemler, veritabanında değişiklik yapma yeteneğine sahiptir. Bu durumda, realm.add(item) ifadesiyle belirtilen Item öğesi, veritabanına eklenir. Eğer bu işlem başarılı bir şekilde gerçekleşirse, yazma işlemi otomatik olarak tamamlanır.
                realm.add(item)
            }
        } catch { //Eğer herhangi bir hata oluşursa, bu blok çalışır. Hata durumunda, hatayı yazdırır. Hata durumları, genellikle veritabanına erişimle ilgili sorunlardan kaynaklanabilir.
            print("Error saving item \(error)")
        }
        tableView.reloadData() //Bu satır, tabloyu güncellemek için reloadData() metodunu çağırır. Bu, veritabanına yeni bir öğe eklenip eklendiğini görsel olarak tabloya yansıtmak için kullanılır. Eğer bu satır olmasaydı, kullanıcı yeni eklenen öğeyi göremeyebilirdi.
    }
    
    func loadItems() { //Bu fonksiyon, veritabanından öğeleri yükleyip bir diziye sıralayarak ve ardından tabloyu güncelleyerek öğeleri gösterir.
        if let selectedCategory = selectedCategory { //Bu kontrol yapısı, eğer bir "selectedCategory" (seçili kategori) varsa, o kategoriye ait öğeleri yükler. Eğer seçili kategori yoksa, tüm "Item" öğelerini yükler.
            toDoItems = selectedCategory.items.sorted(by: [ //Seçili kategoriye ait öğeler, "done" (tamamlanma durumu) özelliğine göre artan (ascending: true) sırayla ve "dateCreated" (oluşturulma tarihi) özelliğine göre azalan (ascending: false) sırayla sıralanır. Bu sıralama, tamamlanan öğelerin en altta, en yeni öğelerin en üstte görünmesini sağlar.
    
                SortDescriptor(keyPath: "done", ascending: true),
                SortDescriptor(keyPath: "dateCreated", ascending: false)
            ])
        } else { //Eğer bir kategori seçilmemişse, tüm "Item" öğeleri yüklenir ve aynı şekilde sıralama yapılır.
            toDoItems = realm.objects(Item.self).sorted(by: [
                SortDescriptor(keyPath: "done", ascending: true),
                SortDescriptor(keyPath: "dateCreated", ascending: false)
            ])
        }
        tableView.reloadData() //Bu satır, tabloyu güncellemek için reloadData() metodunu çağırır. Bu işlem, yüklenen ve sıralanan öğeleri tabloya yansıtmak için kullanılır. Eğer bu satır olmasaydı, kullanıcı güncellenmiş öğeleri göremezdi.
    }
    
    func updateModel(at indexPath: IndexPath) { //Bu fonksiyon, belirli bir indexPath'teki öğeyi silmek için kullanılır.
        
        if let itemForDeletion = self.toDoItems?[indexPath.row] { //Bu satır, belirtilen indexPath'teki öğenin var olup olmadığını kontrol eder. Eğer varsa, bu öğeyi kullanarak silme işlemi gerçekleştirilir.
            do {
                try self.realm.write { //Bu blok, Realm veritabanında bir yazma işlemi başlatır ve içindeki kod, bu yazma işlemi sırasında gerçekleştirilecek işlemleri tanımlar. Bu durumda, realm.delete(itemForDeletion) ifadesi, belirtilen öğeyi veritabanından siler. Bu işlem, try-catch bloğu içine alınmıştır çünkü veritabanına erişimde hatalar oluşabilir ve bu hatalar yakalanarak işlenebilir.
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
                
            }
        } //Bu fonksiyon, belirli bir indexPath'teki öğeyi silerek, bu silme işlemini veritabanına yansıtarak ve ardından tabloyu güncelleyerek kullanıcıya gösterir.
    }
}

extension ItemTableViewController: UISearchBarDelegate {
    
    // Diğer searchBarDelegate fonksiyonları...
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { //Bu fonksiyon, bir UISearchBar nesnesinin metin değişikliklerini dinler ve bu değişikliklere göre öğeleri filtreleyerek tabloyu günceller.
        if searchText.isEmpty { //Bu kontrol yapısı, eğer arama çubuğu boşsa (yani hiçbir şey yazılmamışsa), tüm öğelerin gösterilmesini sağlar. Eğer arama çubuğuna bir şey yazılmışsa, bu yazılan metni içeren öğeleri filtrelemek üzere bir sorgu yapılır.
            
            // Eğer arama çubuğu boşsa, tüm öğeleri göster
            toDoItems = realm.objects(Item.self).sorted(by: [ //Eğer arama çubuğu boşsa, tüm öğeler (realm.objects(Item.self)) alınır ve "done" (tamamlanma durumu) özelliğine göre artan (ascending: true) sırayla ve "dateCreated" (oluşturulma tarihi) özelliğine göre azalan (ascending: false) sırayla sıralanır.
                SortDescriptor(keyPath: "done", ascending: true),
                SortDescriptor(keyPath: "dateCreated", ascending: false)
            ])
        } else {
            // Arama çubuğunda yazılan metni içeren öğeleri filtrele
            toDoItems = realm.objects(Item.self) //Eğer arama çubuğuna bir şey yazılmışsa, filter fonksiyonu kullanılarak "title" özelliği içinde yazılan metni içeren öğeler filtrelenir. Burada [cd] seçeneği, büyük/küçük harf duyarlı olmayan bir arama yapılmasını sağlar. Sonrasında yine sıralama yapılır.
                .filter("title CONTAINS[cd] %@", searchText)
                .sorted(by: [
                    SortDescriptor(keyPath: "done", ascending: true),
                    SortDescriptor(keyPath: "dateCreated", ascending: false)
                ])
        }
        tableView.reloadData() //Bu satır, tabloyu güncellemek için reloadData() metodunu çağırır. Bu, yüklenen ve filtrelenen öğeleri tabloya yansıtmak için kullanılır. Eğer bu satır olmasaydı, kullanıcı güncellenmiş öğeleri göremezdi.
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) { //Bu fonksiyon, kullanıcı arama çubuğundaki iptal düğmesine tıkladığında çağrılır. İptal düğmesine tıklandığında, tüm öğeleri yükleyip göstermek ve klavyeyi kapatmak gibi işlemleri gerçekleştirir.
        // İptal düğmesine basıldığında, tüm öğeleri göster
        loadItems() //Bu, tüm öğeleri yükleyip gösteren bir fonksiyondur. İptal düğmesine basıldığında, bu fonksiyon çağrılarak tüm öğelerin gösterilmesi sağlanır.
        searchBar.resignFirstResponder() //Bu ifade, klavyeyi kapatmaya yarar. resignFirstResponder metodunun çağrılması, klavyenin ekrandan kaybolmasını sağlar.
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //Bu fonksiyon, kullanıcı arama çubuğundaki arama düğmesine tıkladığında çağrılır. Arama düğmesine tıklandığında, klavyeyi kapatma işlemi gerçekleştirir.
        // Arama düğmesine tıklandığında klavyeyi kapat
        searchBar.resignFirstResponder() //Bu ifade, klavyeyi kapatmaya yarar. Arama düğmesine tıklanıldığında, bu fonksiyon çağrılarak klavyenin ekrandan kaybolması sağlanır.
    }
}

