# SwiftUIFlux
A very naive implementation of Redux using Combine BindableObject to serve as an example

## Usage

You first have to make a struct which will contain your application state and it needs to conform to `FluxState`. You can add any substate you want.

``` Swift
import SwiftUIFlux

struct AppState: FluxState {
    var moviesState: MoviesState
}

struct MoviesState: FluxState, Codable {
    var movies: [Int: Movie] = [:]
}

struct Movie: Codable, Identifiable {
    let id: Int
    
    let original_title: String
    let title: String
}
```

The second piece you'll need is your app main reducer, and any substate reducer you need. 

``` Swift
import SwiftUIFlux

func appStateReducer(state: AppState, action: Action) -> AppState {
    var state = state
    state.moviesState = moviesStateReducer(state: state.moviesState, action: action)
    return state
}

func moviesStateReducer(state: MoviesState, action: Action) -> MoviesState {
    var state = state
    switch action {
    case let action as MoviesActions.SetMovie:
        state.movies[action.id] = action.movie

    default:
        break
    }

    return state
}
```
Finally, you have to add you `Store` wich will contain you current application state `AppState` as a global constant.

```Swift
let store = Store<AppState>(reducer: appStateReducer,
                            middleware: nil,
                            state: AppState(),
                            queue: .main)
```

You instantiate with your initial application state and your main reducer function.

And now the magical part, you can inject the store at the root of your SwiftUI application using `.environmentObject()`. 
The most common way to do it is in your `SceneDelegate` when your initial view hierarchy is created.

``` Swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let controller = UIHostingController(rootView: HomeView().environmentObject(store))
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
        }
}

```

Now, in any view where you want to access your application state, you can do it using `@EnvironmentObject`

``` Swift
struct MovieDetail : View {
    @EnvironmentObject var store: Store<AppState>
    
    let movieId: Int
    
    var movie: Movie {
        return store.state.moviesState.movies[movieId]
    }

    //MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                MovieBackdrop(movieId: movie.id)
                // ...
            }
        }
    }
}
```

At some point, you'll need to make changes to your state, for that you need to create and dispatch `Action`

`AsyncAction` is available as part of this library, and is the right place to do network query, if'll be executed by an internal `middleware` when you dispatch it.

You can then chain any action when you get a result or an error.

``` Swift
struct MoviesActions {
    struct FetchDetail: AsyncAction {
        let movie: Int
        
        func execute(state: FluxState?, dispatch: @escaping DispatchFunction) {
            APIService.shared.GET(endpoint: .movieDetail(movie: movie))
            {
                (result: Result<Movie, APIService.APIError>) in
                switch result {
                case let .success(response):
                    dispatch(SetDetail(movie: self.movie, movie: response))
                case .failure(_):
                    break
                }
            }
        }
    }

    struct SetDetail: Action {
        let movie: Int
        let movie: Movie
    }

}
```

And then finally, you can dispatch them, if you look at the code of the reducer at the begining of this readme, you'll see how actions are reduced. The reducer is the only function where you are allowed to mutate your state.

As everything in the AppState are Swift `struct`, you actually return a new copy of your state, which is alligned with the Redux archutecture. 

``` Swift
struct MovieDetail : View {
    @EnvironmentObject var store: Store<AppState>
    
    let movieId: Int
    
    var movie: Movie {
        return store.state.moviesState.movies[movieId]
    }

    func fetchMovieDetails() {
        store.dispatch(action: MoviesActions.FetchDetail(movie: movie.id))
    }

    //MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                MovieBackdrop(movieId: movie.id)
                // ...
            }
        }.onAppear {
            self.fetchMovieDetails()
        }
    }
}
```