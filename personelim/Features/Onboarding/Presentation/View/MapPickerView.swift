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
    @State private var selectedTitle: String = ConstantStrings.selectedLocation
    @State private var selectedAddress: String?

    @State private var camera: MapCameraPosition = .automatic
    @StateObject private var locationManager = LocationPermissionManager()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapContent

                topSearchContent

                bottomContent
            }
            .navigationTitle(ConstantStrings.mapPickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .onAppear {
                locationManager.ensurePermissionAndStart()
            }
            .onChange(of: isSearchFocused) { _, focused in
                if focused {
                    withAnimation(.easeInOut) {
                        showResults = true
                    }
                }
            }
        }
    }

    // MARK: - Map

    private var mapContent: some View {
        MapReader { proxy in
            Map(position: $camera) {
                if let coordinate = selectedCoordinate {
                    Marker(selectedTitle, coordinate: coordinate)
                }
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { point in
                guard let coordinate = proxy.convert(point, from: .local) else {
                    return
                }

                selectCoordinate(
                    coordinate,
                    title: ConstantStrings.pickedFromMapTitle,
                    address: nil
                )

                Task {
                    await reverseGeocode(coordinate)
                }

                isSearchFocused = false

                withAnimation(.easeInOut) {
                    showResults = false
                }
            }
        }
    }

    // MARK: - Top Search

    private var topSearchContent: some View {
        VStack(spacing: 10) {
            searchBar

            if showResults {
                resultsOverlay
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.secondary)

                TextField(ConstantStrings.searchPlaceholder, text: $query)
                    .font(.system(size: 15, weight: .medium))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await search()
                        }
                    }

                if !query.isEmpty {
                    Button {
                        query = ""
                        results = []

                        withAnimation(.easeInOut) {
                            showResults = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )

            Button {
                Task {
                    await search()
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Results

    private var resultsOverlay: some View {
        VStack(spacing: 0) {
            if results.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: query.isEmpty ? "magnifyingglass" : "mappin.slash")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(query.isEmpty ? ConstantStrings.searchEmptyHint : ConstantStrings.searchNoResult)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text(ConstantStrings.mapSearchInstruction)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(14)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(results, id: \.self) { item in
                            resultRow(item)

                            if item != results.last {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    private func resultRow(_ item: MKMapItem) -> some View {
        Button {
            selectMapItem(item)
            isSearchFocused = false

            withAnimation(.easeInOut) {
                showResults = false
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name ?? "-")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(formattedAddress(item.placemark))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom

    private var bottomContent: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                HStack {
                    Spacer()

                    Button {
                        goToMyLocation()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(locationManager.canUseLocation ? .blue : .secondary)
                            .frame(width: 48, height: 48)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(!locationManager.canUseLocation)
                }

                selectedLocationCard

                saveButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    private var selectedLocationCard: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(selectedCoordinate == nil ? Color.gray.opacity(0.12) : Color.blue.opacity(0.12))

                Image(systemName: selectedCoordinate == nil ? "mappin.slash" : "mappin.and.ellipse")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(
                        selectedCoordinate == nil
                        ? .secondary
                        : .blue
                    )
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(
                    selectedCoordinate == nil
                    ? ConstantStrings.locationNotSelected
                    : selectedTitle
                )
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(selectedAddress ?? ConstantStrings.mapSelectionInstruction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
    }

    private var saveButton: some View {
        Button {
            guard let coordinate = selectedCoordinate else { return }

            onSelect(
                MapPickResult(
                    coordinate: coordinate,
                    address: selectedAddress
                )
            )

            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")

                Text(ConstantStrings.saveButton)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(selectedCoordinate == nil ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(selectedCoordinate == nil)
    }

    // MARK: - Search

    private func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            results = []

            withAnimation(.easeInOut) {
                showResults = true
            }

            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed

        if let location = locationManager.lastLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.2,
                    longitudeDelta: 0.2
                )
            )
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems

            withAnimation(.easeInOut) {
                showResults = true
            }
        } catch {
            results = []

            withAnimation(.easeInOut) {
                showResults = true
            }
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        guard let coordinate = item.placemark.location?.coordinate else {
            return
        }

        let address = formattedAddress(item.placemark)

        selectCoordinate(
            coordinate,
            title: item.name ?? ConstantStrings.selectedLocation,
            address: address
        )
    }

    private func selectCoordinate(
        _ coordinate: CLLocationCoordinate2D,
        title: String,
        address: String?
    ) {
        selectedCoordinate = coordinate
        selectedTitle = title
        selectedAddress = address

        camera = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            )
        )
    }

    // MARK: - My Location

    private func goToMyLocation() {
        if let location = locationManager.lastLocation {
            let coordinate = location.coordinate

            selectCoordinate(
                coordinate,
                title: ConstantStrings.currentLocationTitle,
                address: nil
            )

            Task {
                await reverseGeocode(coordinate)
            }
        } else {
            locationManager.startUpdates()
        }
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(
                CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )

            if let placemark = placemarks.first {
                let addressParts: [String?] = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]

                let address = addressParts
                    .compactMap { $0 }
                    .joined(separator: ", ")

                if !address.isEmpty {
                    selectedAddress = address
                }
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

        let address = parts
            .compactMap { $0 }
            .joined(separator: ", ")

        return address.isEmpty ? "-" : address
    }
}

// MARK: - Location Manager

@MainActor
final class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()

    var canUseLocation: Bool {
        authorizationStatus == .authorizedWhenInUse ||
        authorizationStatus == .authorizedAlways
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

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        lastLocation = locations.last
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) { }
}
