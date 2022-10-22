//
//  SimilarMovieCell.swift
//  TheMovieDB
//
//  Created by Mostafa Nafie on 22/10/2022.
//

import UIKit
import Kingfisher

class SimilarMovieCell: UICollectionViewCell {
    static let size: CGSize = .init(width: 200, height: 300)
    
    // MARK: - Outlets
    @IBOutlet private weak var posterImageView: UIImageView!
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.kf.indicatorType = .activity
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }
    
    // MARK: - Public Methods
    func configure(_ movie: Movie) {
        posterImageView.kf.indicatorType = .activity
        posterImageView.kf.setImage(with: movie.posterURL,
                                    placeholder: UIImage(named: "poster-placeholder"))
    }
}
