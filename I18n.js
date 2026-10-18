// Localization helper for Omarchy Controller Plugin

var translations = {
  en: {
    title: "Xbox Controller",
    status_bt: "CONNECTED (BLUETOOTH)",
    status_wired: "CONNECTED (USB CABLE)",
    status_disconnected: "DISCONNECTED",
    label_model: "Model",
    label_connection: "Connection",
    label_battery: "Battery Level",
    type_bt: "Bluetooth (Wireless)",
    type_wired: "USB (Wired)",
    type_none: "None",
    btn_connect: "Connect",
    btn_disconnect: "Disconnect",
    btn_refresh: "Refresh",
    tooltip_disconnected: "Xbox Controller: Disconnected\nClick to open panel",
    tooltip_status: "Status: Connected",
    battery_wired: "Wired (Powered)"
  },
  tr: {
    title: "Xbox Kontrolcüsü",
    status_bt: "BAĞLI (BLUETOOTH)",
    status_wired: "BAĞLI (USB KABLO)",
    status_disconnected: "BAĞLI DEĞİL",
    label_model: "Model",
    label_connection: "Bağlantı Türü",
    label_battery: "Pil Durumu",
    type_bt: "Bluetooth (Kablosuz)",
    type_wired: "USB (Kablolu)",
    type_none: "Yok",
    btn_connect: "Bağlan",
    btn_disconnect: "Bağlantıyı Kes",
    btn_refresh: "Yenile",
    tooltip_disconnected: "Xbox Kontrolcüsü: Bağlı Değil\nTıklayarak paneli açın",
    tooltip_status: "Durum: Bağlı",
    battery_wired: "Kablolu (Güç bağlı)"
  }
};

function getLocale() {
  var lang = "";
  try {
    lang = (Qt.locale().name || "").toLowerCase();
  } catch (e) {
    lang = "en";
  }
  if (lang.indexOf("tr") === 0) return "tr";
  return "en";
}

function t(key) {
  var loc = getLocale();
  var dict = translations[loc] || translations["en"];
  if (dict && dict[key] !== undefined) return dict[key];
  if (translations["en"][key] !== undefined) return translations["en"][key];
  return key;
}
