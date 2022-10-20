//
//  SequencesViewController.swift
//  
//
//  Created by Zachary Shakked on 10/10/22.
//

import UIKit

class SequencesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var chatSequences: [ChatSequence] = []
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    
    init(chatSequences: [ChatSequence]) {
        self.chatSequences = chatSequences
        super.init(nibName: "SequencesViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCell(type: SequenceCell.self)
        tableView.register(UINib(nibName: "SequenceCell", bundle: Bundle.module), forCellReuseIdentifier: SequenceCell.reuseIdentifier)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonPressed))
    }
    
    @objc func cancelButtonPressed() {
        dismiss(animated: true)
    }
    
    @objc func refreshButtonPressed() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        GrowKit.shared.refresh { [unowned self] in
            DispatchQueue.main.async {
                self.chatSequences = ChatKit.shared.chatSequences
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshButtonPressed))
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSequences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SequenceCell = tableView.dequeueReusableCell(withIdentifier: SequenceCell.reuseIdentifier, for: indexPath) as! SequenceCell
        let chatSequence = chatSequences[indexPath.row]
        cell.titleLabel.text = chatSequence.id
        cell.subtitleLabel.text = "\(chatSequence.chats.count) chats"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatSequence = chatSequences[indexPath.row].copy()
        let chatVC = ChatViewController(chatSequence: chatSequence, theme: ChatKit.shared.theme)
        self.present(chatVC, animated: true)
    }
}
