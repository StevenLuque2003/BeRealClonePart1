import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var isFetchingMore = false
    private var postLimit = 10
    private var skipCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)

        queryPosts() // Fetch the initial posts
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Ensure posts are queried again if needed
        queryPosts()
    }
    
    private func queryPosts(loadMore: Bool = false, completion: (() -> Void)? = nil) {
        guard !isFetchingMore else { return }
        isFetchingMore = true

        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate)
            .limit(postLimit)
            .skip(skipCount)

        query.find { [weak self] result in
            guard let self = self else { return }
            self.isFetchingMore = false

            switch result {
            case .success(let newPosts):
                if loadMore {
                    self.posts.append(contentsOf: newPosts)
                } else {
                    self.posts = newPosts
                }
                self.skipCount = self.posts.count
            case .failure(let error):
                self.showAlert(description: error.localizedDescription)
            }

            completion?()
        }
    }

    @IBAction func onTapLogOut(_ sender: Any) {
        showConfirmLogoutAlert()
    }
    
    @objc private func onPullToRefresh() {
        refreshControl.tintColor = .white
        refreshControl.beginRefreshing()
        queryPosts { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let tableViewHeight = scrollView.frame.size.height

        // Check if the user is nearing the bottom to load more posts
        if offsetY > contentHeight - tableViewHeight * 1.5 {
            queryPosts(loadMore: true)
        }
    }
}

