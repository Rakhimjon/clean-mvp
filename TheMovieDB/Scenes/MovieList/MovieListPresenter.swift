//
//  MovieListPresenter.swift
//  TheMovieDB
//
//  Created by Mostafa Nafie on 20/10/2022.
//

import Foundation

final class MovieListPresenter {
    enum MovieListPresenterState {
        case popularMovies
        case searchMovies
    }
    
    // MARK: - Poperties
    weak var view: MovieListView!
    
    // MARK: - Private Properties
    private let popularMoviesUseCase: PopularMoviesUseCase!
    private let searchMoviesUseCase: SearchMoviesUseCase!
    private var currentState: MovieListPresenterState = .popularMovies
    private var popularMovies: [Movie] =  []
    private var currentPage = 1
    private var totalPages = 1
    private var query = ""
    
    // MARK: - Init
    init(popularMoviesUseCase: PopularMoviesUseCase, searchMoviesUseCase: SearchMoviesUseCase) {
        self.popularMoviesUseCase = popularMoviesUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
    }
    
    // MARK: - Public Methods
    func fetchPopularMovies(at page: Int = 1) {
        popularMoviesUseCase.fetchMovies(at: page) { [weak self] result in
            self?.handleMoviesResult(result)
        }
    }
    
    func popularMoviesCount() -> Int {
        popularMovies.count
    }
    
    func popularMovie(at row: Int) -> Movie {
        popularMovies[row]
    }
    
    /// Check if the last movie is about to be displayed to handle pagination
    /// - Parameter indexPath: The indexPath of the cell that is about to be displayed
    func reachedMovie(at row: Int) {
        // check that this is the last item
        let lastFetchedRow = popularMoviesCount() - 1
        guard lastFetchedRow == row else { return }
        // check that currentPage is less that the totalPages
        guard currentPage < totalPages else { return }
        currentPage += 1
        
        switch currentState {
            case .popularMovies:
                fetchPopularMovies(at: currentPage)
            case .searchMovies:
                search(with: query, at: currentPage)
        }
    }
    
    func search(with query: String, at page: Int = 1) {
        guard !query.isEmpty else {
            switchToPopularMoviesState()
            return
        }
        
        if currentState == .popularMovies {
            switchToSearchMoviesState(query)
        }
        
        searchMoviesUseCase.fetchMovies(by: query, at: page) { [weak self] result in
            self?.handleMoviesResult(result)
        }
    }
}

// MARK: - Private helpers
private extension MovieListPresenter {
    func handleMoviesResult(_ result: Result<(totalPages: Int, movies: [Movie]), Error>) {
        switch result {
            case .success(let response):
                self.totalPages = response.totalPages
                self.popularMovies += response.movies
                self.view.showMovies()
            case .failure(let error):
                print(#function, error)
        }
    }
    
    func switchToPopularMoviesState() {
        query = ""
        currentPage = 1
        popularMovies = []
        fetchPopularMovies()
        currentState = .popularMovies
    }
    
    func switchToSearchMoviesState(_ query: String) {
        self.query = query
        currentPage = 1
        popularMovies = []
        currentState = .searchMovies
    }
}
