import SwiftUI
import PlaygroundSupport

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
    callback(
      data
        .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
    )
    }
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(query: "prime \(n)") { result in
        callback(
          result
            .flatMap {
              $0.queryresult
                .pods
                .first(where: { $0.primary == .some(true) })?
                .subpods
                .first?
                .plaintext
            }
            .flatMap(Int.init)
        )
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState

    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: state)) {
                    Text("Counter Demo")
                }
                NavigationLink(destination: FavoritePrimesView(state: state)) {
                    Text("Favorite Primes")
                }
            }.navigationBarTitle("State management")
        }
    }
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

import Combine

class AppState: ObservableObject {
    @Published var count: Int = 0
    @Published var favoritePrimes: [Int] = []
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: Int? = nil
    @State var isShowingAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.state.count -= 1
                }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: {
                    self.state.count += 1
                }) {
                    Text("+")
                }
            }
            Button(action: {
                self.isPrimeModalShown = true
            }) {
                Text("Is this prime?")
            }
            Button(action: {
                nthPrime(self.state.count) { prime in
                    self.alertNthPrime = prime
                    self.isShowingAlert = true
                }
            }) {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown, onDismiss: {
            self.isPrimeModalShown = false
        }) {
            IsPrimeModalView(state: self.state)
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("The \(ordinal(self.state.count)) prime is \(alertNthPrime!)"))
        }
    }
}

struct FavoritePrimesView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                 Text("\(prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

struct IsPrimeModalView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        if isPrime((self.state.count)) {
            Text("\(self.state.count) is prime!")
        } else {
            Text("\(self.state.count) is not prime :(")
        }
        if self.state.favoritePrimes.contains(self.state.count) {
            Button(action: {
                self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
            }) {
                Text("Remove from favorite primes")
            }
        } else {
            Button(action: {
                self.state.favoritePrimes.append(self.state.count)
            }) {
                Text("Save to favorite primes")
            }
        }
    }
}


PlaygroundPage.current.liveView = UIHostingController(rootView: ContentView(state: AppState()))

