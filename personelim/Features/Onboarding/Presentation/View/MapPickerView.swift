import SwiftUI
import MapKit
import CoreLocation

struct MapPickResult {
    let coordinate: CLLocationCoordinate2D
    let address: String?
}

struct MapPickerView: View {

    @Environment(\.dismiss) private var dismiss
    let onSelect: (MapPickResult) -> Void


    @State private var query: String = ""
    @State private var results: [MKMapItem] = []
    @State private var showResults: Bool = false
    @FocusState private var isSearchFocused: Bool
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedTitle: String = "Seçilen Konum"
    @State private var selectedAddress: String?
    @State private var camera: MapCameraPosition = .automatic
    @StateObject private var locationManager = LocationPermissionManager()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                MapReader { proxy in
                    Map(position: $camera) {
                        if let c = selectedCoordinate {
                            Marker(selectedTitle, coordinate: c)
                        }
                    }
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { point in
                        guard let coord = proxy.convert(point, from: .local) else { return }
                        selectCoordinate(coord, title: "Haritadan seçildi", address: nil)
                        Task { await reverseGeocode(coord) }

                        isSearchFocused = false
                        withAnimation(.easeInOut) { showResults = false }
                    }
                }

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Yer ara (örn: Kadıköy)", text: $query)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onSubmit { Task { await search() } }

                            if !query.isEmpty {
                                Button {
                                    query = ""
                                    results = []
                                    withAnimation(.easeInOut) { showResults = false }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Button("Ara") {
                            Task { await search() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

                    if showResults {
                        resultsOverlay
                            .padding(.horizontal, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }

                VStack {
                    Spacer()

                    HStack {
                        Spacer()
                        Button {
                            goToMyLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        }
                        .disabled(!locationManager.canUseLocation)
                        .padding(.trailing, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Konum Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        guard let coord = selectedCoordinate else { return }
                        onSelect(MapPickResult(coordinate: coord, address: selectedAddress))
                        dismiss()
                    }
                    .disabled(selectedCoordinate == nil)
                }
            }
            .onAppear {
                locationManager.ensurePermissionAndStart()
            }
            .onChange(of: isSearchFocused) { _, focused in
                if focused {
                    withAnimation(.easeInOut) { showResults = true }
                }
            }
        }
    }

    // MARK: - Results Overlay UI
    private var resultsOverlay: some View {
        VStack(spacing: 0) {
            if results.isEmpty {
                HStack {
                    Text(query.isEmpty ? "Arama yapabilirsiniz." : "Sonuç bulunamadı.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(results, id: \.self) { item in
                            Button {
                                selectMapItem(item)
                                isSearchFocused = false
                                withAnimation(.easeInOut) { showResults = false }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "-")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(formattedAddress(item.placemark))
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 10)
    }

    // MARK: - Search
    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            withAnimation(.easeInOut) { showResults = true }
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed

        if let loc = locationManager.lastLocation {
            request.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
            withAnimation(.easeInOut) { showResults = true }
        } catch {
            results = []
            withAnimation(.easeInOut) { showResults = true }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        guard let coord = item.placemark.location?.coordinate else { return }
        let address = formattedAddress(item.placemark)
        selectCoordinate(coord, title: item.name ?? "Seçilen Konum", address: address)
    }

    private func selectCoordinate(_ coord: CLLocationCoordinate2D, title: String, address: String?) {
        selectedCoordinate = coord
        selectedTitle = title
        selectedAddress = address

        camera = .region(
            MKCoordinateRegion(
                center: coord,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    // MARK: - My Location
    private func goToMyLocation() {
        if let loc = locationManager.lastLocation {
            let coord = loc.coordinate
            selectCoordinate(coord, title: "Mevcut Konum", address: nil)
            Task { await reverseGeocode(coord) }
        } else {
            locationManager.startUpdates()
        }
    }

    // MARK: - Reverse Geocode
    private func reverseGeocode(_ coord: CLLocationCoordinate2D) async {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            if let pm = placemarks.first {
                let addrParts: [String?] = [
                    pm.thoroughfare,
                    pm.subThoroughfare,
                    pm.locality,
                    pm.administrativeArea,
                    pm.country
                ]
                let addr = addrParts.compactMap { $0 }.joined(separator: ", ")
                if !addr.isEmpty { selectedAddress = addr }
            }
        } catch { }
    }

    private func formattedAddress(_ placemark: MKPlacemark) -> String {
        let parts: [String?] = [
            placemark.thoroughfare,
            placemark.subThoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
        return parts.compactMap { $0 }.joined(separator: ", ")
    }
}

// MARK: - Location Manager (Permission + lastLocation)
@MainActor
final class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    var canUseLocation: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = manager.authorizationStatus
    }

    func ensurePermissionAndStart() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdates()
        default:
            break
        }
    }

    func requestWhenInUse() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        manager.startUpdatingLocation()
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdates()
        default:
            stopUpdates()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}
