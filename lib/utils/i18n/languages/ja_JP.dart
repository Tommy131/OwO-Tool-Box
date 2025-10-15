// ============================================================================
// 日本語翻訳
// ============================================================================

import '../localization_keys.dart';

class JaJP {
  static const Map<String, String> translations = {
    // ========== 一般 ==========
    L18nKeys.appTitle: 'OwO! System Tools',
    L18nKeys.ok: 'OK',
    L18nKeys.cancel: 'キャンセル',

    // ========== ナビゲーション ==========
    L18nKeys.menu: 'メニュー',
    L18nKeys.home: 'ホーム',
    L18nKeys.settings: '設定',
    L18nKeys.about: '概要',

    // ========== ウェルカムページ ==========
    L18nKeys.welcome: 'ようこそ',
    L18nKeys.welcomeMessage: 'HanskiJayが開発した多機能システムアシスタント。',
    L18nKeys.welcomeDescription:
        '複数のプラットフォームに対応した自動レイアウトをサポートし、スマートフォン、タブレット、デスクトップに最適化されています。',
    L18nKeys.exploreFeatures: '機能を確認',

    // ========== 言語設定 ==========
    L18nKeys.languageSettings: '言語設定',

    // ========== テーマ設定 ==========
    L18nKeys.themeSettings: 'テーマ設定',
    L18nKeys.themeColorSettings: 'テーマカラー',
    L18nKeys.cyberpunkTheme: 'サイバーパンクテーマ',
    L18nKeys.lightTheme: 'ライトテーマ',
    L18nKeys.darkTheme: 'ダークテーマ',
    L18nKeys.systemTheme: 'システムに従う',
    L18nKeys.defaultTheme: 'デフォルトテーマ',
    L18nKeys.techTheme: 'テックテーマ',
    L18nKeys.natureTheme: 'ナチュラルテーマ',
    L18nKeys.sunsetTheme: 'サンセットテーマ',
    L18nKeys.oceanTheme: 'オーシャンテーマ',

    // ========== ビジュアル効果 ==========
    L18nKeys.visualEffects: 'ビジュアルエフェクト',
    L18nKeys.visualEffectsDescription: 'サイバーパンクテーマ専用のエフェクト',
    L18nKeys.matrixRainEffect: 'マトリックスレイン効果',
    L18nKeys.matrixRainDescription: 'マトリックス風コードレインアニメーション',
    L18nKeys.glowEffect: 'グロー効果',
    L18nKeys.glowEffectDescription: 'ヘッダー文字のネオングロー',
    L18nKeys.scanningLine: 'スキャンライン',
    L18nKeys.scanningLineDescription: 'サイバーパンク風スキャンアニメーション',
    L18nKeys.glitchEffect: 'グリッチ効果',
    L18nKeys.glitchEffectDescription: 'ランダムなピクセルの揺らぎ',

    // ========== アプリ情報 ==========
    L18nKeys.appInfo: 'アプリ情報',
    L18nKeys.appName: 'アプリ名',
    L18nKeys.appDescription: 'アプリの説明',
    L18nKeys.appVersion: 'バージョン',
    L18nKeys.developerInfo: '開発者情報',
    L18nKeys.developerName: '開発者',
    L18nKeys.contactEmail: '連絡用メール',
    L18nKeys.flutterVersion: 'Flutter バージョン',
    L18nKeys.serviceHomepage: 'サービスホームページ',
    L18nKeys.openSource: 'オープンソース情報',
    L18nKeys.openSourceDescription:
        '本プロジェクトは MIT ライセンスの下で公開されています。貢献・提案を歓迎します。',
    L18nKeys.viewSourceCode: 'ソースコードを表示',
    L18nKeys.license: 'ライセンス',
    L18nKeys.supportDevelopment: '開発を支援',
    L18nKeys.donationDescription: 'ご支援はプロジェクトの継続的な発展に役立ちます。',
    L18nKeys.donateNow: '今すぐ寄付',
    L18nKeys.topDonors: '寄付ランキング TOP 5',
    L18nKeys.cannotOpenUrl: 'リンクを開けません',
    L18nKeys.loadFailed: '読み込みに失敗しました',
    L18nKeys.retry: '再試行',
    L18nKeys.noDonorsYet: '寄付記録はまだありません',

    // ========== 利用規約 ==========
    L18nKeys.userAgreement: '利用規約',
    L18nKeys.agreementContent: '1. 本アプリケーションフレームワークは学習および開発目的のみに使用してください。\n'
        '2. 関連法規を遵守してください。\n'
        '3. モバイル、タブレット、PC などのマルチプラットフォームに対応しています。\n'
        '4. 開発者は最終的な解釈権を保持します。\n'
        '5. MIT オープンソースライセンスに基づいています。\n'
        '6. 使用前にドキュメントをよくお読みください。\n'
        '7. 開発者は最終的な解釈権を保持します。',
    L18nKeys.github: 'GitHub',

    // ========== デバイス情報 ==========
    L18nKeys.deviceInfo: 'デバイス情報',
    L18nKeys.screenSize: '画面サイズ',
    L18nKeys.deviceType: 'デバイスの種類',
    L18nKeys.mobileDevice: 'モバイルデバイス',
    L18nKeys.tabletDevice: 'タブレットデバイス',
    L18nKeys.desktopDevice: 'デスクトップデバイス',
    L18nKeys.layoutMode: 'レイアウトモード',
    L18nKeys.adaptiveLayout: 'アダプティブレイアウト',

    // ========== ウィンドウ制御 ==========
    L18nKeys.minimize: '最小化',
    L18nKeys.maximize: '最大化',
    L18nKeys.restore: '元に戻す',
    L18nKeys.close: '閉じる',

    // ========== 設定ページ (SettingsScreen) ==========
    // 設定カテゴリ
    L18nKeys.commonSettings: '共通設定',
    L18nKeys.hostMonitoringSettings: 'ホスト監視設定',

    // セクションタイトル
    L18nKeys.refreshSettings: '更新設定',
    L18nKeys.hostCheckSettings: 'ホストチェック設定',
    L18nKeys.alertSettings: 'アラート設定',
    L18nKeys.alertThresholds: 'アラートしきい値',
    L18nKeys.notificationSettings: '通知設定',

    // 更新設定
    L18nKeys.pollingInterval: 'ホストポーリング間隔',
    L18nKeys.secondsSuffix: '秒',
    L18nKeys.refreshIntervalHint: '更新間隔を入力（秒）',
    L18nKeys.refreshIntervalTip: '推奨値は 1〜10 秒です。短すぎるとパフォーマンスに影響する可能性があります。',

    // ホストチェック設定
    L18nKeys.checkTimeout: 'チェックタイムアウト',
    L18nKeys.timeoutHint: 'タイムアウトを入力（秒）',
    L18nKeys.hostTimeoutTip: 'ホスト状態チェックの推奨タイムアウト：3〜10 秒。',
    L18nKeys.backgroundCheckInterval: 'バックグラウンドチェック間隔',
    L18nKeys.minutesSuffix: '分',
    L18nKeys.checkIntervalHint: 'チェック間隔を入力（分）',
    L18nKeys.backgroundCheckTip: '静的なホスト状態チェックの推奨間隔：5〜30 分。',

    // アラート設定（メインスイッチ）
    L18nKeys.enableAlerts: 'アラートを有効にする',
    L18nKeys.enableAlertsSubtitle: 'リソース使用率がしきい値を超えた場合に通知を送信します。',

    // アラートしきい値（スライダー）
    L18nKeys.cpuUsage: 'CPU 使用率',
    L18nKeys.memoryUsage: 'メモリ使用率',
    L18nKeys.diskUsage: 'ディスク使用率',
    L18nKeys.uploadRate: 'アップロード速度',
    L18nKeys.downloadRate: 'ダウンロード速度',
    L18nKeys.kbPerSecond: ' KB/秒',

    // 通知設定
    L18nKeys.notifyOnDisconnect: '切断時の通知',
    L18nKeys.soundEnabled: 'サウンド通知',
    L18nKeys.vibrationEnabled: 'バイブレーション通知',
    L18nKeys.vibrationNote: 'モバイルデバイスのみ有効',

    // 操作：保存・検証・ダイアログ・結果表示
    L18nKeys.saveSettings: '設定を保存',
    L18nKeys.invalidRefreshInterval: '有効な更新間隔を入力してください（最低 1 秒）。',
    L18nKeys.invalidHostCheckTimeout: '有効なタイムアウトを入力してください（1〜60 秒）。',
    L18nKeys.invalidHostCheckInterval: '有効なチェック間隔を入力してください（1〜1440 分）。',
    L18nKeys.longRefreshTitle: '更新間隔が長すぎます',
    // プレースホルダー {seconds} は intervalSeconds に置き換えられます
    L18nKeys.longRefreshContent:
        '設定した更新間隔は {seconds} 秒です。データ更新が遅れる可能性があります。続行しますか？',
    L18nKeys.settingsSaved: '設定が保存されました',
  };
}
