//
//  DataSources.swift
//  PhotoLibrary
//
//  Created by Mohssen Fathi on 10/23/17.
//  Copyright © 2017 mohssenfathi. All rights reserved.
//

import UIKit

open
class AlbumsDataSource: NSObject {
    
    let albumCellIdentifier = "AlbumCell"
    let albums = PhotoLibrary.collections()
    var configureCell: ((_ cell: UICollectionViewCell, _ indexPath: IndexPath) -> ())?
  
}

extension AlbumsDataSource: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCellIdentifier", for: indexPath)
        configureCell?(cell, indexPath)
        return cell
    }

}
