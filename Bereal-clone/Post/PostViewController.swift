import UIKit
import ParseSwift
import PhotosUI

class PostViewController: UIViewController{
    
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    private var pickedImage: UIImage?
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        
        var config = PHPickerConfiguration()

        config.filter = .images

        config.preferredAssetRepresentationMode = .current

        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)

        picker.delegate = self

        present(picker, animated: true)
    }
    
    
    @IBAction func shareTapped(_ sender: Any) {
        view.endEditing(true)

        
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        var post = Post()

        post.imageFile = imageFile
        post.caption = captionTextField.text

        post.user = Users.current

        post.save { [weak self] result in

            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")

                    if var currentUser = Users.current {

                        currentUser.lastPostedDate = Date()

                        currentUser.save { [weak self] result in
                            switch result {
                            case .success(let user):
                                print("✅ User Saved! \(user)")

                                DispatchQueue.main.async {
                                    self?.navigationController?.popViewController(animated: true)
                                }

                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }

    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }

        let imagePicker = UIImagePickerController()

        imagePicker.sourceType = .camera

        imagePicker.allowsEditing = true

        imagePicker.delegate = self

        present(imagePicker, animated: true)

    }
    
    
    
    @IBAction func screenTapped(_ sender: Any) {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    

}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
           provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           guard let image = object as? UIImage else {

              self?.showAlert()
              return
           }

            if error != nil {
               self?.showAlert()
              return
           } else {

              DispatchQueue.main.async {

                 self?.previewImage.image = image

                 self?.pickedImage = image
              }
           }
        }
    }
    

}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("❌📷 Unable to get image")
            return
        }

        previewImage.image = image

        pickedImage = image
    }
}
