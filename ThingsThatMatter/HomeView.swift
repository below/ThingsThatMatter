//
//  HomeView.swift
//  MatterCommissionerPOC
//
//  Created by Alexander von Below on 24.03.23.
//

import SwiftUI
import HomeKit

struct HexFormatStyle: FormatStyle {
    var prefix: String = ""
    func format(_ value: UInt64) -> String {
        String(format: "\(prefix)%x", value)
    }
    func prefix(_ prefix: String) -> Self {
        var result = self
        result.prefix = prefix
        return result
    }
}

extension FormatStyle where Self == HexFormatStyle {
    static var hex: HexFormatStyle {
        HexFormatStyle()
    }
}

@available(iOS 16.1, *)
struct HomeView: View {
    @StateObject private var homeManager = HomeObserver(homeManager: HMHomeManager())
    
    var body: some View {
        NavigationView {
        let homes = homeManager.homes
            List {
                ForEach(homes, id:\.uniqueIdentifier) { home in
                    Section(home.name) {
                        let matterAccessories = home.accessories.compactMap { accessory -> HMAccessory? in
                            if accessory.matterNodeID != 0 {
                                return accessory
                            } else {
                                return nil
                            }
                        }
                        ForEach(matterAccessories, id:\.uniqueIdentifier) { accessory in
                            if let matterNodeID = accessory.matterNodeID {
                                NavigationLink {
                                    DeviceView(home: home, accessory: accessory)
                                } label: {
                                    LabeledContent(accessory.name, value: matterNodeID, format: .hex.prefix("0x"))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

class HomeObserver: NSObject, HMHomeManagerDelegate, ObservableObject {
    var homeManager: HMHomeManager
    @Published var homes: [HMHome] = []
    
    init(homeManager: HMHomeManager) {
        self.homeManager = homeManager
        super.init()
        self.homeManager.delegate = self
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.homes = manager.homes
        debugPrint("Got new homes \(manager.homes)")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.1, *) {
            HomeView()
        } else {
            Text ("iOS 16 only")
        }
    }
}
