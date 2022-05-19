//
//  GeneralVM.swift
//  OnlySwitch
//
//  Created by Jacklandrin on 2022/1/5.
//

import AppKit

let menubarIconKey = "menubarIconKey"
let appearanceColumnCountKey = "appearanceColumnCountKey"
let showAdsKey = "showAdsKey"

class GeneralVM:ObservableObject {
    @Published var cacheSize:String = ""
    @Published var needtoUpdateAlert = false
    @Published var showProgress = false
    @Published var newestVersion = UserDefaults.standard.string(forKey: newestVersionKey) ?? ""
    @Published var supportedLanguages = SupportedLanguages.langList
    @Published var showMenubarIconPopover = false
    @Published var menubarIcons = ["menubar_0", "menubar_1", "menubar_2", "menubar_3"]
    
    private let checkUpdatePresenter = CheckUpdatePresenter()
    
    @UserDefaultValue(key: menubarIconKey, defaultValue: "menubar_0")
    var currentMenubarIcon:String
    {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: changeMenuBarIconNotificationName, object: currentMenubarIcon)
        }
    }
    
    @UserDefaultValue(key: appearanceColumnCountKey, defaultValue: SwitchListAppearance.single.rawValue)
    var currentAppearance:String {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: changePopoverAppearanceNotificationName, object: nil)
        }
    }
    
    @UserDefaultValue(key: showAdsKey, defaultValue: true)
    var showAds:Bool {
        didSet {
            objectWillChange.send()
            NotificationCenter.default.post(name: changeSettingNotification, object: nil)
        }
    }
    
    var latestVersion:String {
        return checkUpdatePresenter.latestVersion
    }
    
    var isTheNewestVersion:Bool {
        return checkUpdatePresenter.isTheNewestVersion
    }
    
    func checkUpdate() {
        self.showProgress = true
        checkUpdatePresenter.checkUpdate(complete: { success in
            if success {
                self.newestVersion = self.checkUpdatePresenter.latestVersion
                UserDefaults.standard.set(self.newestVersion, forKey: newestVersionKey)
                UserDefaults.standard.synchronize()
                self.needtoUpdateAlert = !self.checkUpdatePresenter.isTheNewestVersion
            }
            self.showProgress = false
        })
    }
    
    
    func downloadDMG() {
        checkUpdatePresenter.downloadDMG{ success, path in
            guard success, let path = path else {return}
            self.openDMG(path: path)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSApp.terminate(self)
            }
        }
    }
    
    private func openDMG(path:String) {
        let finder = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.finder")
        let configuration: NSWorkspace.OpenConfiguration = NSWorkspace.OpenConfiguration()
        configuration.promptsUserIfNeeded = true
        NSWorkspace.shared.open([URL(fileURLWithPath: path)], withApplicationAt: finder!, configuration: configuration, completionHandler: nil)
    }
}

enum SwitchListAppearance:String {
    case single = "Single Column"
    case dual = "Two Columns"
}

struct Language:Hashable {
    let name:String
    let code:String
}

struct SupportedLanguages {
    static let english = Language(name: "English", code: "en")
    static let simplifiedChinese = Language(name: "简体中文", code: "zh-Hans")
    static let german = Language(name: "Deutsch", code: "de")
    static let croatian = Language(name: "Hrvatski", code: "hr")
    static let turkish = Language(name: "Türkçe", code: "tr")
    static let polish = Language(name: "Polski", code: "pl")
    static let filipino = Language(name: "Filipino", code: "fil")
    static let dutch = Language(name: "Nederlands", code: "nl")
	static let italian = Language(name: "Italiano", code: "it")
    static let russian = Language(name: "Русский", code: "ru")
    static let spanish = Language(name: "Español", code: "es")
    static let japanese = Language(name: "日本語", code: "ja")
    
	static let langList = [SupportedLanguages.english,
						   SupportedLanguages.simplifiedChinese,
						   SupportedLanguages.german,
						   SupportedLanguages.croatian,
						   SupportedLanguages.turkish,
						   SupportedLanguages.polish,
						   SupportedLanguages.filipino,
						   SupportedLanguages.dutch,
						   SupportedLanguages.italian,
                           SupportedLanguages.russian,
                           SupportedLanguages.spanish,
                           SupportedLanguages.japanese]
    
    static func getLangName(code:String) -> String {
        let lang = SupportedLanguages.langList.filter{$0.code == code}.first
        return lang?.name ?? "English"
    }
}
