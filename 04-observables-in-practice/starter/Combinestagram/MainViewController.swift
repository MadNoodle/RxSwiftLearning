/*
 * Copyright (c) 2016-present Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift

class MainViewController: UIViewController {
  
  // dispose bag for main controller
  private let bag = DisposeBag()
  // Variable for images initialized to empty
  private let images = Variable<[UIImage]>([])
  
  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  override func viewDidLoad() {
    super.viewDidLoad()
    // fill preview when add button pressed
    images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        guard let preview = self?.imagePreview else { return}
        preview.image = UIImage.collage(images: photos, size: preview.frame.size)
      }).disposed(by: bag)
    
    // update number of photos in navbar
    images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        self?.updateUI(photos: photos)
      }).disposed(by: bag)
  }
  
  @IBAction func actionClear() {
    // emit a new value of empty UIImage array
    images.value = []
  }

  @IBAction func actionSave() {
    guard let preview = imagePreview.image else { return}
    
    PhotoWriter.save(preview)
    .asSingle()
      .subscribe(
        onSuccess: { [weak self] id in
        self?.showMessage("Success", description: "Your image has been saved with id: \(id)")
        self?.actionClear()
      },
                 onError: { [weak self] error in
        self?.showMessage("Error", description: error.localizedDescription)
      }).disposed(by: bag)
  }

  @IBAction func actionAdd() {
    let photosViewController = storyboard!.instantiateViewController(
      withIdentifier: "PhotosViewController") as! PhotosViewController
    photosViewController.selectedPhotos
      .subscribe(onNext: { [weak self] newImage in
        guard let images = self?.images else { return }
        images.value.append(newImage)
        }, onDisposed: {
          print("completed photo selection")
      })
      .disposed(by: bag)
    navigationController!.pushViewController(photosViewController, animated: true)
  }

  func updateUI(photos: [UIImage]) {
    // if 2 conditions are true then button is enabled
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    // if there is a photo then u can clear
    buttonClear.isEnabled = photos.count > 0
    // disabled addButton if there iis 6 photos
    itemAdd.isEnabled = photos.count < 6
    // show current photo count in navbar
    title = photos.count > 0 ? "\(photos.count) photos": "Collage"
  }
  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
}
