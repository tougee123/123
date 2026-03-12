# GitHub Actions iOS 12 打包说明（Xcode 15.4）

## 1. 你需要准备
- Apple Developer 证书 `.p12`
- 对应描述文件 `.mobileprovision`
- 项目的 `TEAM_ID`、`Bundle Identifier`、`Provisioning Profile Name`

## 2. 配置仓库 Secrets
在 GitHub 仓库 `Settings -> Secrets and variables -> Actions` 添加：
- `BUILD_CERTIFICATE_BASE64`: `base64` 编码后的 `.p12`
- `P12_PASSWORD`: 证书导出密码
- `KEYCHAIN_PASSWORD`: CI 临时 keychain 密码（自定义）
- `BUILD_PROVISION_PROFILE_BASE64`: `base64` 编码后的 `.mobileprovision`

## 3. 修改导出配置
编辑 `ci/ExportOptions.plist`：
- `teamID` 改为你的 Team ID
- `YOUR_BUNDLE_IDENTIFIER` 改为真实 bundle id
- `YOUR_PROFILE_NAME` 改为描述文件名称

## 4. 触发工作流
`Actions -> Build IPA (Xcode 15.4) -> Run workflow`

当前仓库已固定为：
- `workspace_path`: `CmdCode/CmdCode.xcworkspace`
- `scheme`: `CmdCode`

你只需选择 `configuration`（默认 `Release`）。

可选：
- `package_mode = unsigned`：无需证书/描述文件，生成未签名 IPA（仅用于编译验证）
- `package_mode = signed`：需要完整签名 secrets，生成可安装分发 IPA

## 5. iOS 12 注意点
- 项目内 `IPHONEOS_DEPLOYMENT_TARGET` 必须 <= `12.0`
- 三方依赖必须支持 iOS 12
- Xcode 15.4 可以构建 iOS 12 目标，但不代表依赖也兼容
