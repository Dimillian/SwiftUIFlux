![Swift](https://github.com/Dimillian/SwiftUIFlux/workflows/Swift/badge.svg)

# SwiftUIFlux
A very naive implementation of Redux using Combine BindableObject to serve as an example

## Usage

In this little guide, I'll show you two ways to access your proprerties from your state, one very naive, which works by using direct access to store.state global or injected `@EnvironmentObject` and the other one if you want to use `ConnectedView`.

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
Finally, you have to add you `Store` which will contain you current application state `AppState` as a global constant.

```Swift
let store = Store<AppState>(reducer: appStateReducer,
                            middleware: nil,
                            state: AppState())
```

You instantiate with your initial application state and your main reducer function.

And now the part where you inject it in your SwiftUI app.
The most common way to do it is in your `SceneDelegate` when your initiate your view hierarchy is created. You should use the provided `StoreProvider` to wrap you whole app root view hiearchy inside it. It'll auto magically inject the store as an `@EnvironmentObject` in all your views. 

``` Swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
           
            let controller = UIHostingController(rootView:
                StoreProvider(store: store) {
                    HomeView()
            })
            
            window.rootViewController = controller
            self.window = window
            window.makeKeyAndVisible()
        }
        }
}

```


From there, there are two ways to access your state properties. 

In any view where you want to access your application state, you can do it using `@EnvironmentObject`

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

This is the naive, brutal, not so redux compliant way, but it works. 

Note that any view where you add explicilty add `@EnvironmentObject var store: Store<AppState>`will be redraw anywhere it's needed as your state is updated. The diff is done at the view level by SwiftUI. 

And it's efficient enough that this library don't have to provide custom subscribers or a diffing mechanism. This is where it shine compared to a UIKit implementation. 

You can also use `ConnectedView,` this is the new prefered way to do it as it feels more redux like. But the end result is exactly the same. You just have a better separation of concerns, no wild call to store.state and proper local properties.

``` Swift
struct MovieDetail : ConnectedView {  
    struct Props {
        let movie: Movie
    }  

    let movieId: Int
    

    func map(state: AppState, dispatch: @escaping DispatchFunction) -> Props {
        return Props(movie: state.moviesState.movies[movieId]!)
    }

    func body(props: Props) -> some View {
        ZStack(alignment: .bottom) {
            List {
                MovieBackdrop(movieId: props.movie)
                // ...
            }
        }
    }
}
```
You have to implement a map function which convert properties from your state to local view props. And also a new body method which will provide you with your computed props at render time.

You can look at more complexe examples from my app [here](https://github.com/Dimillian/MovieSwiftUI/blob/master/MovieSwift/MovieSwift/views/shared/contextMenu/MovieContextMenu.swift) and [there](https://github.com/Dimillian/MovieSwiftUI/blob/master/MovieSwift/MovieSwift/views/components/movieDetail/MovieDetail.swift).



At some point, you'll need to make changes to your state, for that you need to create and dispatch `Action`

`AsyncAction` is available as part of this library, and is the right place to do network query, it'll be executed by an internal `middleware` when you dispatch it.

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

As everything in the AppState are Swift `struct`, you actually return a new copy of your state, which is aligned with the Redux achitecture. 

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
