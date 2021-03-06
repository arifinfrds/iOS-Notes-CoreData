//
//  NoteViewController.swift
//  Notes
//
//  Created by Arifin Firdaus on 1/6/18.
//  Copyright © 2018 Arifin Firdaus. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    
    
    //varRK: - Properties
    
    @IBOutlet var noteTableView: UITableView!
    
    var notes = [Note]()
    
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        fetchNotes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        noteTableView.dataSource = self
        noteTableView.delegate = self
        noteTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // setupDummyContent()
        
    }
    
    func setupDummyContent() {
        var experimentNotes = [Note]()
        experimentNotes.append(Note(id: "123123", title: "CoreDataTest", content: "CoreDataTest"))
    }
    
    
    // MARK: - Private API's
    
    private func setupViews() {
        // setup navigation bar
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Resources.Color().applicationBaseColor
        
        // setup cell
        let nib = UINib(nibName: "NoteCell", bundle: nil)
        noteTableView.register(nib, forCellReuseIdentifier: "note_cell")
    }
    
    // CoreData fetch request
    private func fetchNotes() {
        Repository.shared.requestFetchNotes { (notes, success) in
            if !success {
                return
            }
            guard let notes = notes else {
                return
            }
            self.notes = notes
            noteTableView.reloadData()
        }
    }
    
    // CoreData delete
    private func deleteNoteFromCoreData(at indexPath: IndexPath) {
        let note = notes[indexPath.row]
        Repository.shared.requestDeleteNoteFromCoreData(note: note) { success in
            print(success.description)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_edit_note_view_controller" {
            if let navVC = segue.destination as? UINavigationController {
                let editNoteVC = navVC.topViewController as! EditNoteViewController
                
                if let selectedIndexPath = noteTableView.indexPathForSelectedRow {
                    editNoteVC.noteId = notes[selectedIndexPath.row].id
                }
            }
        }
    }
    
}


// MARK - UITableViewDataSource

extension NoteViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "note_cell", for: indexPath) as! NoteCell
        cell.dataSource = notes[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            deleteNoteFromCoreData(at: indexPath)
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

    }
}


// MARK: - UITableViewDelegate

extension NoteViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segue_edit_note_view_controller", sender: indexPath)
    }
}




