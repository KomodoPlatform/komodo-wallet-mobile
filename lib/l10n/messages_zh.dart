// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<Object> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static m0(name) => "成功新增 ${name}!";

  static m1(title) => "仅显示具有${title}地址的联系人";

  static m2(abbr) => "您无法将基金发送到${abbr}地址，因为${abbr}未激活。请转到投资组合页面";

  static m3(appName) => "不${appName}是非托管应用。我们不会存储任何敏感数据，包括您的私钥、助记词或PIN。此数据仅存储在用户的设备上，不会转移。您的资产只由您掌控。";

  static m4(appName) => "${appName}有适用于Android和iPhone系统的手机程序，以及适用于Windows、Mac和Linux操作系统的桌面程序。";

  static m5(appName) => "其他DEX（去中心化交易所）通常只允许您使用代理代币交易基于单个区块链网络的资产，并且只能用一个基金下一个订单。\n但用${appName}您可以在两个不同的区块链网络之间进行交易，且无需代理代币。您还可以用一个基金下多个订单。例如，您可以用KMD、QTUM或VRSC兑0.1 BTC，第一个订单成交后自动取消其他所有订单";

  static m6(appName) => "几个因素决定了每次交易的处理时间。交易资产的区块时间取决于各自的网络（比特币通常是最慢的）。此外，用户可以自定义安全偏好。例如，您可以要求${appName}在确认KMD交易为最终交易前确认3次，这使得交易时间短于等待公证的<a href=\"https://komodoplatform.com/security-delayed-proof-of-work-dpow/\">时间</a>.";

  static m7(appName) => "在｛appName｝上进行交易时，需要考虑两种费用。\n1.｛appName｝收取约0.13%（交易量的1/777，但不低于0.0001）作为吃单交易的交易费用，挂单交易不收费。\n2.在进行原子交换交易时，无论挂单还是吃单，都需要向相关区块链支付常规的网络费用\n网络费用具体取决于你选择的交易对，不同交易对费用可能大大不同。";

  static m8(name, link, appName, appCompanyShort) => "是的 ${appName} 通过 <a href=\"${link}\">${appCompanyShort} ${name}</a>提供支持。团队和社区总是乐于提供帮助！";

  static m9(appName) => "不是${appName} 是完全去中心化的。不会限制任何第三方用户访问。";

  static m10(appName, appCompanyShort) => "${appName} 由${appCompanyShort}团队开发。${appCompanyShort}是最成熟的区块链项目之一，致力于开发创新解决方案，如原子交换、延迟工作量证明和可互操作的多链架构。";

  static m11(appName) => "当然。更多信息，您可以查阅我们的<a href=\"https://developers.atomicdex.io/\">开发者文档</a> ，或与我们联系询问合作细节。有具体的技术问题吗？｛appName｝开发者社区随时乐意提供帮助！";

  static m12(batteryLevelCritical) => "您的电池电量过低 (${batteryLevelCritical}%) ，无法安全地进行交换。请先充电，然后重试。";

  static m13(batteryLevelLow) => "您的电池电量低于 ${batteryLevelLow}%。请充电。";

  static m14(seconde) => "正在进行交易匹配，请等待 ${seconde} 秒!";

  static m15(index) => "请输入第 ${index}个单词";

  static m16(index) => "您的助記詞的第 ${index}個单词是什麼？";

  static m17(name) => "确认删除该联系人${name}？";

  static m18(iUnderstand) => "自定义助记词的安全性可能比自动生成的符合BIP39规范的助记词或私钥（WIF）低，更容易被破解。如您已了解风险并知道您正在做什么，请在下面的框中输入\"${iUnderstand}\"。";

  static m19(abbr) => "输入${abbr}地址";

  static m20(gas) => "燃料不足-至少使用｛gas｝Gwei";

  static m21(appName, appCompanyLong) => "本最终用户许可协议（“EULA”）是您与｛appCompanyLong｝之间的法律协议。\n本EULA协议适用于您直接从${appCompanyLong}或间接通过${appCompanyLong}授权的实体、经销商或分销商获取和使用我们的${appName}移动软件（“软件”、“移动应用程序”、“应用程序”或“应用”）。\n在完成安装和使用${appName}移动软件之前，请仔细阅读本EULA协议。它提供使用${appName}移动软件的许可证，以及保修信息和免责声明。\n如果您注册了${appName}移动软件的测试版，本EULA协议也将管辖该试用。单击“接受”或安装和/或使用${appName}移动软件，即表示您确认接受本软件并同意受本EULA协议条款约束。\n如果您代表公司或其他法律实体签订本EULA协议，则表示您有权约束该实体及其附属公司遵守这些条款和条件。如果您没有此类权限或不同意本EULA协议的条款和条件，请不要安装或使用本软件，并且不要接受本EULA协议。\n本EULA协议仅适用于${appCompanyLong}提供的软件，无论此处是否提及或描述其他软件。这些条款也适用于${appCompanyLong}软件的任何更新、补充、基于互联网的服务和支持服务，除非交付时附带其他条款。否则仍适用这些条款\n\n许可证授予\n${appCompanyLong}特此授予您根据本EULA协议条款在您的设备上使用${appName}移动软件的个人、不可转让、非独家许可。\n\n您可以在您的控制下加载${appName}移动软件（例如PC端、笔记本电脑端、移动设备或平板电脑）。您有责任确保您的设备满足${appName}移动软件的最基本的安全性和资源需求\n您不允许：\n（a） 编辑、更改、修改、改编、翻译或以其他方式更改软件的全部或任何部分，也不允许将软件的全部和任何部分与任何其他软件结合或并入任何其他软件，也不能反编译、反汇编或反工程软件或试图进行任何此类操作；\n（b） 复制、模仿、分发、转售或以其他方式将软件用于任何商业目的\n（c） 以任何违反适用的当地、国家或国际法律的方式使用本软件\n（d） 将本软件用于${appCompanyLong}认为违反本EULA协议的任何目的。\n\n知识产权和所有权\n${appCompanyLong}始终保留您最初下载的软件以及您之后下载的所有软件的所有权。本软件（以及本软件中任何性质的版权和其他知识产权，包括对其进行的任何修改）均为${appCompanyLong}的财产。\n${appCompanyLong}保留向第三方授予使用本软件的许可的权利。\n终止\n本EULA协议自您首次使用本软件之日起生效，直至终止。您可以随时书面通知${appCompanyLong}终止本协议。\n如果您未能遵守本EULA协议的任何条款，本协议也将立即终止。一旦协议终止，则本EULA协议授予的许可证也将立即终止，您同意停止访问和使用本软件。如果任何条款在性质上理应地在此协议终止时继续存在,那么这些条款将在本EULA协议终止后继续有效\n适用法律\n本EULA协议以及因本EULA协定而产生或与之相关的任何争议均应受越南法律管辖并根据越南法律进行解释。\n本文件最后更新于2020年1月31日";

  static m22(appCompanyLong) => "${appCompanyLong} 是应用程序中出现或包含的所有商标、服务标志、设计标志、专利、版权、数据库权利和所有其他知识产权的所有者和/或授权用户，除非另有说明。\n除${appCompanyLong} 另有明确说明外，应用程序界面上的所有信息、文本、材料、图形、软件和广告版权均属${appCompanyLong} 、其供应商和许可方\n除非条款中另有规定，否则使用应用程序并不授予您对在应用程序中可能访问的任何此类知识产权的任何权利、所有权、权益或许可。\n我们拥有应用程序中出现的商标的权利或使用许可。未经我们的书面授权，您无权使用这些商标—这样做将侵犯我们或第三方的知识产权。\n或者，如果您事先与我们联系并取得我们的书面同意，我们可能会授权您使用我们应用程序中的内容。";

  static m23(appCompanyShort, appCompanyLong) => "${appCompanyLong} 无法保证您的计算机系统的安全。我们不承担因使用应用程序或用户内容而导致的任何电子存储数据的丢失或损坏或任何计算机系统的损坏的责任。\n${appCompanyLong} 不对应用程序或用户内容的操作做出任何明确或隐晦的声明或保证。您明确同意您完全承担使用本应用程序的风险。\n您同意应用程序中提供的内容和用户内容不构成金融产品、法律或税务建议，您同意不代表用户内容或应用程序。\n在现行法律允许的范围内，基于 “ 现状 ”及“ 现有”基础提供服务\n${appCompanyLong} 明确声明，对于因以下原因导致的任何损失、伤害、索赔、责任或损害，或任何间接、附带、特殊或后果性损害或利润损失，概不负责：\n（a） 应用程序和/或用户内容中的任何错误或遗漏，包括但不限于技术错误和排印错误；\n（b） 通过应用程序中的链接直接或间接访问的任何第三方网站、应用程序或内容，包括但不限于任何错误或遗漏\n（c） 本应用程序或其任何部分的不可用\n（d） 您使用本应用程序\n（e） 您使用与应用程序相关的任何设备或软件\n\n与平台相关的任何服务均按“现状”提供，无任何明示、暗示或法定的陈述或保证。在适用法律允许的最大范围内，我们明确否认对所有权、适销性、特定用途适用性和/或不侵权的任何暗示保证。我们不对平台的持续性、不间断、及时或无错误作出任何声明或保证。\n我们不保证任何平台将没有病毒、恶意软件或其他相关有害材料，也不保证您访问任何平台时不受干扰。产品中的任何缺陷或故障都应提交给提供平台的第三方，而不是${appCompanyShort}。\n\n对于因依赖平台或根据平台所包含的材料或信息而采取的行动导致的任何形式的损失，我们不承担任何责任或义务。\n这是一个测试性的未完善的软件。使用风险自负。不对任何形式的损害做担保。使用本应用程序即代表您同意本条款和条件。";

  static m24(appCompanyLong) => "您同意并理解，使用涉及虚拟货币的服务存在风险，包括但不限于硬件、软件和互联网连接故障的风险，恶意软件引入的风险，以及第三方可能未经授权访问存储在您的钱包中的信息的风险，包括但不限于您的公/私钥。您同意并理解，${appCompanyLong}不对您在使用服务时可能遇到的任何通信故障、中断、错误、失真或延迟负责，无论是何种原因造成的。\n您接受并承认，使用任何虚拟货币网络都存在相关风险，包括但不限于网络协议中未知漏洞或意外变化的风险。您承认并接受${appCompanyLong}对任何加密货币网络没有控制权，并且不对此类风险造成的任何损害负责，包括但不限于无法逆转交易，以及由于错误或欺诈行为导致的任何损失。\n使用涉及虚拟货币的服务的损失风险可能很大，并且可能在瞬息间亏损。此外，价格和流动性会受到不可预测的巨大波动的影响。\n虚拟货币不是法定货币，不受任何主权政府的支持。此外，关于虚拟货币的立法和监管环境不断变化，可能会影响您使用、转移或兑换虚拟货币的能力。\n差价合约是一种复杂的工具，由于杠杆作用，很有可能迅速亏损，风险很高。80.6%的零售投资者账户在与提供者进行差价合约交易时亏损。您应考虑自己是否了解差价合约的运作方式，以及您是否可以承担亏损的高风险。";

  static m25(appCompanyLong) => "您同意${appCompanyLong}及其管理人员、董事、员工、代理、许可方、供应商和应用程序的任何第三方信息提供商不承担因您违反条款而产生的所有损失、费用、损害和成本，包括合理的律师费。\n您还同意对您向${appCompanyLong}提交的信息或材料违反任何法律或违反任何第三方权利的任何索赔（包括但不限于诽谤、侵犯隐私、违反保密、侵犯版权或侵犯任何其他知识产权的索赔）向${appCompanyLong}作出赔偿。";

  static m26(appCompanyLong) => "为了完成交易，任何用${appCompanyLong}创建的虚拟货币交易必须被确认并记录在与相关虚拟货币网络相关的虚拟货币分类账中。这些网络是由独立的第三方支持的去中心化对等网络，不由${appCompanyLong}拥有、把控或运营。\n｛appCompanyLong｝无法控制任何虚拟货币网络，因此不能也无法确保您通过我们的服务提交的任何交易细节将在相关虚拟货币网络上得到确认。您同意并理解，您通过我们的服务提交的交易细节可能无法完成，或可能被用于处理交易的虚拟货币网络严重延迟。我们不保证钱包能够以任何虚拟货币形式转让所有权或权利，也不对所有权做出任何保证。\n一旦交易细节提交给虚拟货币网络，我们将无法帮助您取消或修改您的交易或交易细节。${appCompanyLong}无法控制任何虚拟货币网络，也无法推进任何取消或修改请求。\n如果发生分叉，${appCompanyLong}可能无法支持与您的虚拟货币相关的活动。您同意并理解，如果发生分叉，交易可能无法完成、可能部分完成、错误完成或严重延迟。${appCompanyLong}不对您因分叉直接或间接造成的全部或部分损失负责。\n\n在任何情况下，${appCompanyLong}、其附属公司和服务提供商，或其各自的任何高级职员、董事、代理人、员工或代表，均不对任何利润损失或任何特殊、偶然、间接、无形或因果化的损害负责，无论是基于合同、侵权、疏忽、严格责任或其他，授权或未经授权使用服务，或本协议，即使${appCompanyLong}的授权代表已被告知、已经知晓或应该知晓此类损害的可能性\n\n例如（在不限制前一句的范围的情况下），您不能就利润损失、商业机会损失或其他类型的特殊、附带、间接、无形或因果化损害进行索赔。某些司法管辖区不允许排除或限制附带或间接损害，因此上述限制可能不适用于您。\n我方不对您的任何损失负责，也不对直接或间接因以下原因导致的全部或部分损失或索赔负责：\n（a） 用户过失，如忘记密码、错误交易或错误输入的虚拟货币地址；\n（b） 服务器故障或数据丢失；\n（c） 损坏或不良的钱包或钱包文件；\n（d） 未经授权访问应用程序；\n（e） 任何未经授权的活动，包括但不限于对服务使用黑客、病毒、网络钓鱼、暴力强迫或其他攻击手段。";

  static m27(appCompanyShort, appCompanyLong) => "为避免疑问，｛appCompanyLong｝不提供投资、税务或法律建议，｛AppCompanyLeng｝也不会代表您进行交易。所有 ${appCompanyLong}交易将根据您的订单说明参数和公布的交易执行程序自动执行，您全权负责根据您的个人投资目标、财务状况和风险承受能力确定任何投资、投资策略或相关交易是否适合您。您应该就您的具体情况咨询您的法律或税务专业人士。｛appCompanyShort｝及其所有者、成员、高级职员、董事、合伙人、顾问或参与发布本程序的任何人，都不是注册投资顾问或经纪交易商或与注册投资顾问和经纪交易商有关联的人，且上述任何人都不会推荐购买或出售移动应用程序中描述的任何公司的加密资产或证券，也不会声明对此类加密资产或债券进行投资或交易将有利可图。移动应用程序中包含的信息不打算，也不应构成出售或购买任何加密资产或证券的要约。移动应用程序中提供的信息仅供参考，不应被视为进行任何特定投资或交易的建议或推荐。在做出任何决定之前，请咨询持证的专业人士。本应用程序中包含的意见和分析基于来源可靠的信息，并本着诚信原则按“现状”提供。${appCompanyShort}对此类信息的准确性或完整性不作任何明示、暗示或法定的陈述或保证，如有更改，恕不另行通知。${appCompanyShort}不对与上述内容有关的任何错误或采取的任何行动负责。意见和信仰声明是对本应用程序做出贡献的作者和/或编辑的意见和信仰，仅基于这些作者和/或编辑所拥有的信息。不应推断${appCompanyShort}或此类作者或编辑对所描述的加密资产或公司有任何特殊或更宽泛的知识，或对所介绍的加密资产和公司运营和竞争的行业或市场有任何特定的专业见解。\n关于本程序的信息来自被认为可靠的来源；然而，${appCompanyShort}不负责验证此类信息的准确性，也不保证此类信息是准确或完整的。本程序中包含的某些声明可能是基于当前预期的前瞻性声明。${appCompanyShort}不作任何陈述，也不担保或保证此类前瞻性陈述将被证明是准确的。强烈建议使用${appCompanyShort}应用程序的人员就本文介绍的任何加密资产或公司的投资或交易咨询持证的专业人士。此外，使用本应用程序的人员明确表示，本应用程序中的内容不是也不会成为此类人员投资或交易决策的考虑因素。交易员应通过完成对任何加密资产或公司的尽职调查，独立验证${appCompanyShort}应用程序中提供的信息，并审查该加密资产或企业的完整信息，包括但不限于相关博客更新和新闻稿。\n加密资产和证券过去的表现并不代表未来的结果。本网站上介绍的加密资产和公司可能缺乏活跃的交易市场，并投资于缺乏活跃交易市场的加密资产或证券，或在某些媒体、平台和市场上进行交易，被视为高度投机性且具有高度风险。持有此类加密资产和证券的人都应具备足够的经理能力并准备好承担损失整个交易的风险和实际损失。本应用中的信息不能作为投资决策的依据。使用${appCompanyShort}应用程序的人员应在进行任何投资或进行任何交易之前，确认所有信息的真实性。购买或出售｛appCompanyShort｝可能提供的任何加密资产或证券的决定完全由交易者自行承担风险。作为本应用程序的浏览者和用户，您同意，在任何情况下，您都不会向所有者、成员、高级职员、董事、合伙人、顾问或其他参与本应用发布的人对使用本应用中的信息所造成的任何损失索赔。${appCompanyShort}及其承包商和附属公司可能在加密资产和证券增值或贬值的情况下获利。即使在${appCompanyShort}发布了有关加密资产和公司的正面信息后，此类加密资产和证券也可能会不时被买入或卖出。${appCompanyShort}没有义务将其交易活动或其任何所有者、成员、高级职员、董事、承包商和/或与BC Relations附属公司的所有者、成员，高级职员、主管、承包商和附属公司有关联的任何公司的交易活动告知用户。${appCompanyShort}及其附属公司可能会不时签订购买加密资产或证券的协议，以实现目标。";

  static m28(appCompanyLong) => "本条款在${appCompanyLong}终止之前有效。\n如果终止，您将无权访问应用程序，但对您施加的所有限制以及条款中规定的免责声明和责任限制将在终止后继续有效。\n此类终止不得影响截至终止日期${appCompanyLong}可能对您产生的任何法律权利。\n${appCompanyLong}还可以随时删除整个应用程序或应用程序的任何部分或功能。";

  static m29(appCompanyLong) => "上述规定是为了${appCompanyLong}及其管理人员、董事、员工、代理、许可方、供应商和应用程序的任何第三方信息提供者的利益。这些个人或实体中的每一个都有权代表自己直接向您主张和执行这些规定。";

  static m30(appName, appCompanyLong) => "${appName} 移动程序是一个非托管、去中心化和基于区块链的应用程序，因此${appCompanyLong} 从不存储任何用户数据（帐户和身份验证数据）。\n我们还收集和处理非个人的匿名数据，用于统计和分析，并帮助我们提供更好的服务。\n本文件最后更新于2020年1月31日";

  static m31(appName, appCompanyLong) => "本免责声明适用于应用程序${appName}的内容和服务，并对“应用程序”（“软件”、“移动应用程序”、“应用程序或“应用”）的所有用户有效。\n应用程序归${appCompanyLong} 所有。\n我们保留随时修改以下条款和条件（管理应用程序“${appName}移动程序”的使用）的权利，恕不另行通知，并由我们自行决定。您有责任定期检查本条款和条件，以了解这些条款的任何更新，这些更新将在发布后生效。\n您继续使用应用程序将被视为接受以下条款。\n我们是一家在越南注册成立的公司，这些条款和条件受越南法律管辖。\n如果您不同意这些条款和条件，您不得访问或使用此软件。";

  static m32(appName) => "您不允许从${appName}移动应用程序或用户内容中反编译、解码、反汇编、出租、租赁、出售、再授权或创建衍生作品。您也不得使用任何网络监控或检测软件来确定软件架构，或提取有关使用情况或个人或用户身份的信息\n未经我们事先书面授权，您不得出于商业、非盈利或公共目的复制、修改、模仿、再发布、分发、展示或传送应用程序或用户内容的全部或任何部分";

  static m33(appName, appCompanyLong) => "如果您在移动应用程序中创建了一个帐户，您有责任维护帐户的安全，并对帐户下发生的所有活动以及与此相关的任何其他行为负全部责任。我们不会对您的任何行为或疏忽，以及因此类行为或疏忽而导致的任何类型的损失负责。\n${appName}移动是一个非托管钱包程序，因此 ${appCompanyLong} 在（数据）丢失的情况下无法访问或恢复您的帐户。";

  static m34(appName) => "${appName} 移动程序的最终用户许可协议（EULA）";

  static m35(coin) => "正在向 ${coin} 水龙头发送请求";

  static m36(appCompanyShort) => "${appCompanyShort} 新闻";

  static m37(coin) => "${coin} 费用";

  static m38(coin) => "请激活${coin}.";

  static m39(abbr) => "${abbr}余额不足以支付交易费";

  static m40(coinAbbr) => "${coinAbbr} 不可用:(";

  static m41(coinName, number) => "最低售出量为${number} ${coinName}";

  static m42(coinName, number) => "最低买入量为${number} ${coinName}";

  static m43(buyCoin, buyAmount, sellCoin, sellAmount) => "最小交易量为 ${buyAmount} ${buyCoin}\n(${sellAmount} ${sellCoin})";

  static m44(coinName, number) => "最低售出量为 ${number} ${coinName}";

  static m45(minValue, coin) => "必须大于${minValue} ${coin}";

  static m46(appName) => "请注意，您现在正在使用流量，使用${appName} P2P网络会消耗互联网流量。如果您的手机流量很贵，最好连接WIFI。";

  static m47(coin) => "先激活${coin}并充值余额";

  static m48(number) => "创建${number}订单：";

  static m49(coin) => "${coin}余额过低";

  static m50(coin, fee) => "${coin}不足支付。最低余额为 ${fee} ${coin}";

  static m51(coinName) => "请输入 ${coinName} 量";

  static m52(coin) => "没有足够的${coin} 用于交易！";

  static m53(sell, buy) => "${sell}/${buy} 已成功完成交换";

  static m54(sell, buy) => "${sell}/${buy}交换失败";

  static m55(sell, buy) => "${sell}/${buy}交换开始";

  static m56(sell, buy) => "${sell}/${buy}交换超时";

  static m57(coin) => "您已收到｛coin｝交易！";

  static m58(assets) => "${assets} 资产";

  static m59(coin) => "所有${coin}订单将被取消。";

  static m60(delta) => "划算的: CEX +${delta}%";

  static m61(delta) => "昂贵的: CEX ${delta}%";

  static m62(fill) => "${fill}%已填充";

  static m63(coin) => "数量(${coin})";

  static m64(coin) => "价格 (${coin})";

  static m65(coin) => "总计 (${coin})";

  static m66(abbr) => "${abbr} 未激活。请激活后重试。";

  static m67(appName) => "我可以在哪些设备上使用${appName} ？";

  static m68(appName) => "在${appName} 上交易与在其他DEX上交易有何不同？";

  static m69(appName) => "${appName} 的费用如何计算？";

  static m70(appName) => "${appName} 的背后是谁？";

  static m71(appName) => "是否可以在${appName} 上开发我个人的白标交换？";

  static m72(amount) => "成功！收到 ${amount}KMD";

  static m73(dd) => "${dd} 天";

  static m74(hh, minutes) => "${hh}小时 ${minutes}分钟";

  static m75(mm) => "${mm}分钟";

  static m76(amount) => "点击查看${amount} 交易";

  static m77(coinName, address) => "我的${coinName} 地址:\n${address}";

  static m78(coin) => "请输入要买入的 ${coin} 数量";

  static m79(maxCoins) => "货币最大活跃量为${maxCoins}。请停用一些。";

  static m80(coin) => "${coin}未激活！";

  static m81(coin) => "请输入要卖出的${coin}数量";

  static m82(coin) => "无法激活${coin}";

  static m83(description) => "请选择mp3或wav文件。我们将在${description}时播放它。";

  static m84(description) => "当${description}播放";

  static m85(appName) => "如果您有任何问题，或者认为您发现${appName} 应用程序存在技术问题，请联系我们获取我们团队的支持。";

  static m86(coin) => "请先激活 ${coin} 并充值余额";

  static m87(coin) => "${coin} 余额不足以支付交易费用。";

  static m88(coin, amount) => "${coin} 余额不足以支付交易费用。需要 ${coin} ${amount}";

  static m89(left) => "剩余交易: ${left}";

  static m90(amnt, hash) => "成功解锁 ${amnt} 基金 - 交易: ${hash}";

  static m91(version) => "您正在使用版本${version}";

  static m92(version) => "版本${version}可用。请更新。";

  static m93(appName) => "更新${appName}";

  static m94(coinAbbr) => "我们无法激活 ${coinAbbr}";

  static m95(coinAbbr) => "我们无法激活${coinAbbr}.\n请重启应用程序后重试";

  static m96(appName) => "${appName} 应用程序是新一代多币钱包，具有原生第三代DEX功能和更多功能。";

  static m97(appName) => "您之前禁止${appName} 使用相机。请手动更改手机设置中的相机权限，以便继续二维码扫描";

  static m98(amount, coinName) => "提取 ${amount} ${coinName}";

  static m99(amount, coin) => "您将获得 ${amount} ${coin}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function> {
    "Active" : MessageLookupByLibrary.simpleMessage("活跃"),
    "Applause" : MessageLookupByLibrary.simpleMessage("掌声"),
    "Can\'t play that" : MessageLookupByLibrary.simpleMessage("不能播放"),
    "Failed" : MessageLookupByLibrary.simpleMessage("失败"),
    "Maker" : MessageLookupByLibrary.simpleMessage("挂单"),
    "Play at full volume" : MessageLookupByLibrary.simpleMessage("音量开到最大"),
    "Sound" : MessageLookupByLibrary.simpleMessage("声音"),
    "Taker" : MessageLookupByLibrary.simpleMessage("吃单"),
    "a swap fails" : MessageLookupByLibrary.simpleMessage("交换失败"),
    "a swap runs to completion" : MessageLookupByLibrary.simpleMessage("交换完成"),
    "accepteula" : MessageLookupByLibrary.simpleMessage("同意接受终端使用者授权协议 (EULA)"),
    "accepttac" : MessageLookupByLibrary.simpleMessage("接受条款与条件"),
    "activateAccessBiometric" : MessageLookupByLibrary.simpleMessage("启动生物识别功能"),
    "activateAccessPin" : MessageLookupByLibrary.simpleMessage("启动PIN码保护"),
    "addCoin" : MessageLookupByLibrary.simpleMessage("新增货币"),
    "addingCoinSuccess" : m0,
    "addressAdd" : MessageLookupByLibrary.simpleMessage("添加地址"),
    "addressBook" : MessageLookupByLibrary.simpleMessage("地址簿"),
    "addressBookEmpty" : MessageLookupByLibrary.simpleMessage("地址簿为空"),
    "addressBookFilter" : m1,
    "addressBookTitle" : MessageLookupByLibrary.simpleMessage("地址簿"),
    "addressCoinInactive" : m2,
    "addressNotFound" : MessageLookupByLibrary.simpleMessage("未找到任何内容"),
    "addressSelectCoin" : MessageLookupByLibrary.simpleMessage("选择货币"),
    "addressSend" : MessageLookupByLibrary.simpleMessage("收款人钱包地址"),
    "advanced" : MessageLookupByLibrary.simpleMessage("高级"),
    "all" : MessageLookupByLibrary.simpleMessage("全部"),
    "allowCustomSeed" : MessageLookupByLibrary.simpleMessage("允许自定义助记词"),
    "alreadyExists" : MessageLookupByLibrary.simpleMessage("已存在"),
    "amount" : MessageLookupByLibrary.simpleMessage("数量"),
    "amountToSell" : MessageLookupByLibrary.simpleMessage("卖出量"),
    "answer_1" : m3,
    "answer_10" : m4,
    "answer_2" : m5,
    "answer_3" : m6,
    "answer_4" : MessageLookupByLibrary.simpleMessage("是的，必须保持互联网连接，并确保您的应用程序在运行，才能成功完成原子交换（网络短暂中断通常是可以的）。否则，如果是挂单，会有交易取消的风险，如果是吃单，会有资金损失的风险。原子交换协议要求双方参与者保持在线，并监控所涉及的区块链，确保该过程保持原子性。"),
    "answer_5" : m7,
    "answer_6" : m8,
    "answer_7" : m9,
    "answer_8" : m10,
    "answer_9" : m11,
    "areYouSure" : MessageLookupByLibrary.simpleMessage("您确定吗？"),
    "authenticate" : MessageLookupByLibrary.simpleMessage("身份验证"),
    "automaticRedirected" : MessageLookupByLibrary.simpleMessage("重新激活后，您将自动跳转至投资组合页面。"),
    "availableVolume" : MessageLookupByLibrary.simpleMessage("最大交易量"),
    "back" : MessageLookupByLibrary.simpleMessage("上一步"),
    "backupTitle" : MessageLookupByLibrary.simpleMessage("备份"),
    "batteryCriticalError" : m12,
    "batteryLowWarning" : m13,
    "batterySavingWarning" : MessageLookupByLibrary.simpleMessage("您的手机处于省电模式。请停用此模式或不要将应用程序置于后台，否则，应用程序可能会被系统自动清除，导致交换失败。"),
    "bestAvailableRate" : MessageLookupByLibrary.simpleMessage("兑换率"),
    "builtKomodo" : MessageLookupByLibrary.simpleMessage("基于Komodo"),
    "builtOnKmd" : MessageLookupByLibrary.simpleMessage("基于Komodo"),
    "buy" : MessageLookupByLibrary.simpleMessage("买入"),
    "buyOrderType" : MessageLookupByLibrary.simpleMessage("如果不匹配，则转为挂单"),
    "buySuccessWaiting" : MessageLookupByLibrary.simpleMessage("交换已发起，请等待!"),
    "buySuccessWaitingError" : m14,
    "buyTestCoinWarning" : MessageLookupByLibrary.simpleMessage("警告，你正在购买没有实际价值的测试币!"),
    "camoPinBioProtectionConflict" : MessageLookupByLibrary.simpleMessage("不能同时启用伪装PIN和生物识别保护"),
    "camoPinBioProtectionConflictTitle" : MessageLookupByLibrary.simpleMessage("伪装PIN和生物识别保护冲突"),
    "camoPinChange" : MessageLookupByLibrary.simpleMessage("更改伪装PIN"),
    "camoPinCreate" : MessageLookupByLibrary.simpleMessage("创建伪装PIN"),
    "camoPinDesc" : MessageLookupByLibrary.simpleMessage("如果您用伪装PIN解锁应用程序，将显示一个虚假的低余额，并且设置中不会显示伪装PIN配置选项。"),
    "camoPinInvalid" : MessageLookupByLibrary.simpleMessage("无效的伪装PIN"),
    "camoPinLink" : MessageLookupByLibrary.simpleMessage("伪装PIN"),
    "camoPinNotFound" : MessageLookupByLibrary.simpleMessage("未找到伪装PIN"),
    "camoPinOff" : MessageLookupByLibrary.simpleMessage("关闭"),
    "camoPinOn" : MessageLookupByLibrary.simpleMessage("开启"),
    "camoPinSaved" : MessageLookupByLibrary.simpleMessage("已保存的伪装PIN"),
    "camoPinTitle" : MessageLookupByLibrary.simpleMessage("伪装PIN"),
    "camoSetupSubtitle" : MessageLookupByLibrary.simpleMessage("输入新的伪装PIN"),
    "camoSetupTitle" : MessageLookupByLibrary.simpleMessage("伪装PIN设置"),
    "camouflageSetup" : MessageLookupByLibrary.simpleMessage("伪装PIN设置"),
    "cancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "cancelButton" : MessageLookupByLibrary.simpleMessage("取消"),
    "cancelOrder" : MessageLookupByLibrary.simpleMessage("取消交易"),
    "candleChartError" : MessageLookupByLibrary.simpleMessage("出现错误，稍后重试"),
    "cantDeleteDefaultCoinOk" : MessageLookupByLibrary.simpleMessage("好的"),
    "cantDeleteDefaultCoinSpan" : MessageLookupByLibrary.simpleMessage("是默认币。无法停用默认币。"),
    "cantDeleteDefaultCoinTitle" : MessageLookupByLibrary.simpleMessage("无法停用"),
    "cex" : MessageLookupByLibrary.simpleMessage("CEX(中心化交易所)"),
    "cexChangeRate" : MessageLookupByLibrary.simpleMessage("CEX兑换率"),
    "cexData" : MessageLookupByLibrary.simpleMessage("CEX 数据"),
    "cexDataDesc" : MessageLookupByLibrary.simpleMessage("带有此图标的市场数据（价格、图表等）来源于第三方(<a href=\"https://www.coingecko.com/\">coingecko.com</a>, <a href=\"https://openrates.io/\">openrates.io</a>)."),
    "changePin" : MessageLookupByLibrary.simpleMessage("更改PIN"),
    "checkForUpdates" : MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkOut" : MessageLookupByLibrary.simpleMessage("退出"),
    "checkSeedPhrase" : MessageLookupByLibrary.simpleMessage("检查助记词"),
    "checkSeedPhraseButton1" : MessageLookupByLibrary.simpleMessage("继续"),
    "checkSeedPhraseButton2" : MessageLookupByLibrary.simpleMessage("返回並再次檢查"),
    "checkSeedPhraseHint" : m15,
    "checkSeedPhraseInfo" : MessageLookupByLibrary.simpleMessage("您的助记词很重要——因此我们要确保它是正确的。我们将问您三个关于您的助记词的问题，以确保您可以随时轻松地恢复钱包。"),
    "checkSeedPhraseSubtile" : m16,
    "checkSeedPhraseTitle" : MessageLookupByLibrary.simpleMessage("请再次确认助记词"),
    "chineseLanguage" : MessageLookupByLibrary.simpleMessage("中文"),
    "claim" : MessageLookupByLibrary.simpleMessage("领取"),
    "claimTitle" : MessageLookupByLibrary.simpleMessage("领取您的KMD奖励？"),
    "clickToSee" : MessageLookupByLibrary.simpleMessage("点击查看"),
    "clipboard" : MessageLookupByLibrary.simpleMessage("复制到剪贴板"),
    "clipboardCopy" : MessageLookupByLibrary.simpleMessage("复制到剪贴板"),
    "close" : MessageLookupByLibrary.simpleMessage("关闭"),
    "closeMessage" : MessageLookupByLibrary.simpleMessage("关闭错误信息"),
    "closePreview" : MessageLookupByLibrary.simpleMessage("关闭预览"),
    "code" : MessageLookupByLibrary.simpleMessage("代码"),
    "coinSelectClear" : MessageLookupByLibrary.simpleMessage("清除"),
    "coinSelectNotFound" : MessageLookupByLibrary.simpleMessage("没有活跃币"),
    "coinSelectTitle" : MessageLookupByLibrary.simpleMessage("选择货币"),
    "comingSoon" : MessageLookupByLibrary.simpleMessage("即将上线，敬请期待。。。"),
    "commingsoon" : MessageLookupByLibrary.simpleMessage("交易明细加载中！"),
    "commingsoonGeneral" : MessageLookupByLibrary.simpleMessage("详情载入中！"),
    "commissionFee" : MessageLookupByLibrary.simpleMessage("手续费"),
    "comparedToCex" : MessageLookupByLibrary.simpleMessage("与CEX比较"),
    "configureWallet" : MessageLookupByLibrary.simpleMessage("正在配置您的钱包，请稍候。。。"),
    "confirm" : MessageLookupByLibrary.simpleMessage("确认"),
    "confirmCamouflageSetup" : MessageLookupByLibrary.simpleMessage("确认伪装PIN"),
    "confirmCancel" : MessageLookupByLibrary.simpleMessage("您确定要取消交易吗"),
    "confirmPassword" : MessageLookupByLibrary.simpleMessage("确认密码"),
    "confirmPin" : MessageLookupByLibrary.simpleMessage("确认PIN"),
    "confirmSeed" : MessageLookupByLibrary.simpleMessage("确认助记词"),
    "confirmeula" : MessageLookupByLibrary.simpleMessage("我已了解点击以下的按钮即代表我已阅读并接受终端使用者授权协议(EULA) & 使用条款与条件"),
    "connecting" : MessageLookupByLibrary.simpleMessage("连接中"),
    "contactCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "contactDelete" : MessageLookupByLibrary.simpleMessage("删除联系人"),
    "contactDeleteBtn" : MessageLookupByLibrary.simpleMessage("删除"),
    "contactDeleteWarning" : m17,
    "contactDiscardBtn" : MessageLookupByLibrary.simpleMessage("放弃"),
    "contactEdit" : MessageLookupByLibrary.simpleMessage("编辑"),
    "contactExit" : MessageLookupByLibrary.simpleMessage("退出"),
    "contactExitWarning" : MessageLookupByLibrary.simpleMessage("放弃更改？"),
    "contactNotFound" : MessageLookupByLibrary.simpleMessage("未找到联系人"),
    "contactSave" : MessageLookupByLibrary.simpleMessage("保存"),
    "contactTitle" : MessageLookupByLibrary.simpleMessage("联系人详细信息"),
    "contactTitleName" : MessageLookupByLibrary.simpleMessage("名称"),
    "convert" : MessageLookupByLibrary.simpleMessage("转换"),
    "couldntImportError" : MessageLookupByLibrary.simpleMessage("无法导入："),
    "create" : MessageLookupByLibrary.simpleMessage("交易"),
    "createAWallet" : MessageLookupByLibrary.simpleMessage("创建钱包"),
    "createContact" : MessageLookupByLibrary.simpleMessage("创建联系人"),
    "createPin" : MessageLookupByLibrary.simpleMessage("创建PIN码"),
    "currency" : MessageLookupByLibrary.simpleMessage("货币"),
    "currencyDialogTitle" : MessageLookupByLibrary.simpleMessage("货币"),
    "currentValue" : MessageLookupByLibrary.simpleMessage("当前值"),
    "customFee" : MessageLookupByLibrary.simpleMessage("定制费用"),
    "customFeeWarning" : MessageLookupByLibrary.simpleMessage("选择定制费用前务必明确知晓自己的行为"),
    "customSeedWarning" : m18,
    "dPow" : MessageLookupByLibrary.simpleMessage("Komodo dPoW安全"),
    "date" : MessageLookupByLibrary.simpleMessage("日期"),
    "decryptingWallet" : MessageLookupByLibrary.simpleMessage("钱包解密中"),
    "delete" : MessageLookupByLibrary.simpleMessage("删除"),
    "deleteConfirm" : MessageLookupByLibrary.simpleMessage("确认停用"),
    "deleteSpan1" : MessageLookupByLibrary.simpleMessage("是否要"),
    "deleteSpan2" : MessageLookupByLibrary.simpleMessage("从投资组合中删除？所有不匹配的订单将被取消。"),
    "deleteWallet" : MessageLookupByLibrary.simpleMessage("删除钱包"),
    "deletingWallet" : MessageLookupByLibrary.simpleMessage("删除钱包中"),
    "details" : MessageLookupByLibrary.simpleMessage("详细信息"),
    "deutscheLanguage" : MessageLookupByLibrary.simpleMessage("德语"),
    "developerTitle" : MessageLookupByLibrary.simpleMessage("开发者"),
    "dex" : MessageLookupByLibrary.simpleMessage("DEX"),
    "dexIsNotAvailable" : MessageLookupByLibrary.simpleMessage("DEX不适合该货币"),
    "disclaimerAndTos" : MessageLookupByLibrary.simpleMessage("免责声明 & 使用条款"),
    "done" : MessageLookupByLibrary.simpleMessage("完成"),
    "dontAskAgain" : MessageLookupByLibrary.simpleMessage("不再询问"),
    "dontWantPassword" : MessageLookupByLibrary.simpleMessage("我不想要使用密碼"),
    "duration" : MessageLookupByLibrary.simpleMessage("有效期"),
    "editContact" : MessageLookupByLibrary.simpleMessage("编辑联系人"),
    "emptyCoin" : m19,
    "emptyExportPass" : MessageLookupByLibrary.simpleMessage("加密密码不能为空"),
    "emptyImportPass" : MessageLookupByLibrary.simpleMessage("密码不能为空"),
    "emptyName" : MessageLookupByLibrary.simpleMessage("联系人名称不能为空"),
    "emptyWallet" : MessageLookupByLibrary.simpleMessage("钱包名称不能为空"),
    "enableTestCoins" : MessageLookupByLibrary.simpleMessage("启用测试币"),
    "enablingTooManyAssetsSpan1" : MessageLookupByLibrary.simpleMessage("您已启用"),
    "enablingTooManyAssetsSpan2" : MessageLookupByLibrary.simpleMessage("资产并尝试启用"),
    "enablingTooManyAssetsSpan3" : MessageLookupByLibrary.simpleMessage("更多。最多启用"),
    "enablingTooManyAssetsSpan4" : MessageLookupByLibrary.simpleMessage("请在添加新资产前停用一些资产。"),
    "enablingTooManyAssetsTitle" : MessageLookupByLibrary.simpleMessage("试图启用太多资产"),
    "encryptingWallet" : MessageLookupByLibrary.simpleMessage("錢包加密中"),
    "englishLanguage" : MessageLookupByLibrary.simpleMessage("英文"),
    "enterNewPinCode" : MessageLookupByLibrary.simpleMessage("输入您的新PIN"),
    "enterOldPinCode" : MessageLookupByLibrary.simpleMessage("输入您的旧PIN"),
    "enterPinCode" : MessageLookupByLibrary.simpleMessage("输入您的PIN码"),
    "enterSeedPhrase" : MessageLookupByLibrary.simpleMessage("输入您的助记词"),
    "enterSellAmount" : MessageLookupByLibrary.simpleMessage("您必须先输入卖出数量"),
    "enterpassword" : MessageLookupByLibrary.simpleMessage("继续前请输入密码"),
    "errorAmountBalance" : MessageLookupByLibrary.simpleMessage("余额不足"),
    "errorNotAValidAddress" : MessageLookupByLibrary.simpleMessage("钱包地址错误"),
    "errorNotAValidAddressSegWit" : MessageLookupByLibrary.simpleMessage("尚不支持Segwit地址"),
    "errorNotEnoughGas" : m20,
    "errorTryAgain" : MessageLookupByLibrary.simpleMessage("出现错误, 請重试"),
    "errorTryLater" : MessageLookupByLibrary.simpleMessage("出现错误，請稍後重试"),
    "errorValueEmpty" : MessageLookupByLibrary.simpleMessage("价值太高或太低"),
    "errorValueNotEmpty" : MessageLookupByLibrary.simpleMessage("请输入数据"),
    "estimateValue" : MessageLookupByLibrary.simpleMessage("预估总价"),
    "eulaParagraphe1" : m21,
    "eulaParagraphe10" : m22,
    "eulaParagraphe11" : m23,
    "eulaParagraphe12" : MessageLookupByLibrary.simpleMessage("在访问或使用服务时，您同意对访问和使用我们的服务时的行为负全部责任。在不限制前述条文的一般性的前提下，您同意不会：\n（a） 以任何可能干扰、破坏、负面影响或妨碍其他用户充分享受服务的方式使用服务，也不会以任何方式导致我们的服务被损害，禁用或负担过重\n（b） 使用服务支付、支持或以其他方式参与任何非法活动，包括但不限于非法赌博、欺诈、洗钱或恐怖活动；\n（c） 使用非我们提供的任何机器人、 spider, crawler, scraper 等爬虫程序或其他自动化方式或接口访问我们的服务或提取数据；\n（d） 未经授权使用或试图使用其他用户的钱包或凭证；\n（e） 试图规避我们使用的任何内容筛选技术，或试图访问您无权访问的任何服务或区块；\n（f） 向服务引入任何病毒、特洛伊木马、蠕虫、逻辑炸弹或其他有害材料；\n（g） 未经我们事先书面同意，开发与我们的服务交互的任何第三方应用程序；\n（h） 提供虚假、不准确或误导性信息；\n（i） 鼓励或诱使任何其他人从事本节禁止的任何活动。"),
    "eulaParagraphe13" : m24,
    "eulaParagraphe14" : m25,
    "eulaParagraphe15" : m26,
    "eulaParagraphe16" : m27,
    "eulaParagraphe17" : m28,
    "eulaParagraphe18" : m29,
    "eulaParagraphe19" : m30,
    "eulaParagraphe2" : m31,
    "eulaParagraphe3" : MessageLookupByLibrary.simpleMessage("通过签订本用户（每个访问或使用本网站的主体）协议（书面协议），您声明您是一名超过法定年龄（至少18周岁或以上）的个人，具备签订本用户协议的行为能力，并接受本用户协议的条款和条件的法律约束，这些条款和条件包含在本用户协议中并不时修订。"),
    "eulaParagraphe4" : MessageLookupByLibrary.simpleMessage("我们可以随时更改本用户协议的条款。任何此类更改将在应用程序中发布或在您使用服务时生效。\n每次使用我们的服务时，请仔细阅读用户协议。您继续使用服务则表示您接受当前用户协议的约束。有时我方可能未能或延迟执行或部分执行本用户协议的任何条款，不代表废除任何条款"),
    "eulaParagraphe5" : m32,
    "eulaParagraphe6" : m33,
    "eulaParagraphe7" : MessageLookupByLibrary.simpleMessage("我们不对存在于移动应用程序中的助记词承担责任。在任何情况下，我们不对任何情况下任何形式的损失负责。适当备份账户资料以及助记词是您个人的责任"),
    "eulaParagraphe8" : MessageLookupByLibrary.simpleMessage("您不应仅根据本程序的内容作为或不作为。\n您访问此应用程序这一行为不会在您和我们之间建立顾问客户关系。\n本程序的内容不构成对我们提供的任何金融产品或服务进行投资的邀请或要约。\n本程序中包含的任何建议都是在未考虑您的目标、财务状况或需求的情况下拟定的。在决定是否购买该文件中描述的产品之前，您应考虑我们的风险披露通知。"),
    "eulaParagraphe9" : MessageLookupByLibrary.simpleMessage("我们不保证您可以一直访问应用程序，也不保证您的访问或使用不会出错。\n如果您因任何原因（例如，由于故障、升级、服务器问题、预防性或纠正性维护活动或电信供应中断导致的计算机停机）无法使用应用程序，我们将不承担任何责任。"),
    "eulaTitle1" : m34,
    "eulaTitle10" : MessageLookupByLibrary.simpleMessage("访问与安全"),
    "eulaTitle11" : MessageLookupByLibrary.simpleMessage("知识产权"),
    "eulaTitle12" : MessageLookupByLibrary.simpleMessage("免责声明"),
    "eulaTitle13" : MessageLookupByLibrary.simpleMessage("声明及保证、赔偿和责任限制"),
    "eulaTitle14" : MessageLookupByLibrary.simpleMessage("一般风险因素"),
    "eulaTitle15" : MessageLookupByLibrary.simpleMessage("赔偿"),
    "eulaTitle16" : MessageLookupByLibrary.simpleMessage("与钱包相关的风险披露"),
    "eulaTitle17" : MessageLookupByLibrary.simpleMessage("没有投资建议或经纪业务"),
    "eulaTitle18" : MessageLookupByLibrary.simpleMessage("终止"),
    "eulaTitle19" : MessageLookupByLibrary.simpleMessage("第三方权利"),
    "eulaTitle2" : MessageLookupByLibrary.simpleMessage("条款和条件：（应用程序用户协议）"),
    "eulaTitle20" : MessageLookupByLibrary.simpleMessage("我们的法律义务"),
    "eulaTitle3" : MessageLookupByLibrary.simpleMessage("使用条款条件及免责声明"),
    "eulaTitle4" : MessageLookupByLibrary.simpleMessage("一般用途"),
    "eulaTitle5" : MessageLookupByLibrary.simpleMessage("修改"),
    "eulaTitle6" : MessageLookupByLibrary.simpleMessage("使用限制"),
    "eulaTitle7" : MessageLookupByLibrary.simpleMessage("账户和会员"),
    "eulaTitle8" : MessageLookupByLibrary.simpleMessage("备份"),
    "eulaTitle9" : MessageLookupByLibrary.simpleMessage("一般警告"),
    "exampleHintSeed" : MessageLookupByLibrary.simpleMessage("例如：build case level ..."),
    "exchangeExpedient" : MessageLookupByLibrary.simpleMessage("划算的"),
    "exchangeExpensive" : MessageLookupByLibrary.simpleMessage("昂贵的"),
    "exchangeIdentical" : MessageLookupByLibrary.simpleMessage("与CEX相同"),
    "exchangeRate" : MessageLookupByLibrary.simpleMessage("兑换率"),
    "exchangeTitle" : MessageLookupByLibrary.simpleMessage("兑换"),
    "exportButton" : MessageLookupByLibrary.simpleMessage("导出"),
    "exportContactsTitle" : MessageLookupByLibrary.simpleMessage("联系人"),
    "exportDesc" : MessageLookupByLibrary.simpleMessage("请选择要导出到加密文件中的项目。"),
    "exportLink" : MessageLookupByLibrary.simpleMessage("导出"),
    "exportNotesTitle" : MessageLookupByLibrary.simpleMessage("备注"),
    "exportSuccessTitle" : MessageLookupByLibrary.simpleMessage("项目成功导出"),
    "exportSwapsTitle" : MessageLookupByLibrary.simpleMessage("交换"),
    "exportTitle" : MessageLookupByLibrary.simpleMessage("导出"),
    "fakeBalanceAmt" : MessageLookupByLibrary.simpleMessage("虚假余额"),
    "faqTitle" : MessageLookupByLibrary.simpleMessage("常见问题"),
    "faucetError" : MessageLookupByLibrary.simpleMessage("错误"),
    "faucetInProgress" : m35,
    "faucetName" : MessageLookupByLibrary.simpleMessage("水龙头"),
    "faucetSuccess" : MessageLookupByLibrary.simpleMessage("成功"),
    "faucetTimedOut" : MessageLookupByLibrary.simpleMessage("请求超时"),
    "feedNewsTab" : MessageLookupByLibrary.simpleMessage("新闻"),
    "feedNotFound" : MessageLookupByLibrary.simpleMessage("无内容"),
    "feedNotifTitle" : m36,
    "feedReadMore" : MessageLookupByLibrary.simpleMessage("阅读更多"),
    "feedTab" : MessageLookupByLibrary.simpleMessage("Feed"),
    "feedTitle" : MessageLookupByLibrary.simpleMessage("Feed新闻"),
    "feedUnableToProceed" : MessageLookupByLibrary.simpleMessage("无法继续更新新闻"),
    "feedUnableToUpdate" : MessageLookupByLibrary.simpleMessage("无法获取新闻更新"),
    "feedUpToDate" : MessageLookupByLibrary.simpleMessage("已更新"),
    "feedUpdated" : MessageLookupByLibrary.simpleMessage("Feed新闻已更新"),
    "feedback" : MessageLookupByLibrary.simpleMessage("共享日志文件"),
    "filtersAll" : MessageLookupByLibrary.simpleMessage("全部"),
    "filtersButton" : MessageLookupByLibrary.simpleMessage("过滤器"),
    "filtersClearAll" : MessageLookupByLibrary.simpleMessage("清除所有过滤器"),
    "filtersFailed" : MessageLookupByLibrary.simpleMessage("失败"),
    "filtersFrom" : MessageLookupByLibrary.simpleMessage("起始日期"),
    "filtersMaker" : MessageLookupByLibrary.simpleMessage("挂单"),
    "filtersReceive" : MessageLookupByLibrary.simpleMessage("接收货币"),
    "filtersSell" : MessageLookupByLibrary.simpleMessage("出售货币"),
    "filtersStatus" : MessageLookupByLibrary.simpleMessage("状态"),
    "filtersSuccessful" : MessageLookupByLibrary.simpleMessage("成功"),
    "filtersTaker" : MessageLookupByLibrary.simpleMessage("吃单"),
    "filtersTo" : MessageLookupByLibrary.simpleMessage("截止日期"),
    "filtersType" : MessageLookupByLibrary.simpleMessage("吃单/挂单"),
    "fingerprint" : MessageLookupByLibrary.simpleMessage("指纹"),
    "frenchLanguage" : MessageLookupByLibrary.simpleMessage("法语"),
    "from" : MessageLookupByLibrary.simpleMessage("起始日期"),
    "gasFee" : m37,
    "gasLimit" : MessageLookupByLibrary.simpleMessage("燃料上限"),
    "gasNotActive" : m38,
    "gasPrice" : MessageLookupByLibrary.simpleMessage("燃料价格"),
    "generalPinNotActive" : MessageLookupByLibrary.simpleMessage("常规PIN保护未激活。\n伪装模式将失效\n请激活PIN保护"),
    "getBackupPhrase" : MessageLookupByLibrary.simpleMessage("重要提醒: 請在繼續之前備份助記詞 !"),
    "goToPorfolio" : MessageLookupByLibrary.simpleMessage("前往投资组合"),
    "helpLink" : MessageLookupByLibrary.simpleMessage("帮助"),
    "helpTitle" : MessageLookupByLibrary.simpleMessage("帮助和支持"),
    "hideBalance" : MessageLookupByLibrary.simpleMessage("隐藏余额"),
    "hintConfirmPassword" : MessageLookupByLibrary.simpleMessage("确认密码"),
    "hintCreatePassword" : MessageLookupByLibrary.simpleMessage("创建密码"),
    "hintCurrentPassword" : MessageLookupByLibrary.simpleMessage("当前密码"),
    "hintEnterPassword" : MessageLookupByLibrary.simpleMessage("请输入您的密码"),
    "hintEnterSeedPhrase" : MessageLookupByLibrary.simpleMessage("请输入您的助记词"),
    "hintNameYourWallet" : MessageLookupByLibrary.simpleMessage("命名您的钱包"),
    "hintPassword" : MessageLookupByLibrary.simpleMessage("密码"),
    "history" : MessageLookupByLibrary.simpleMessage("历史记录"),
    "hours" : MessageLookupByLibrary.simpleMessage("小时"),
    "hungarianLanguage" : MessageLookupByLibrary.simpleMessage("匈牙利语"),
    "iUnderstand" : MessageLookupByLibrary.simpleMessage("我已了解"),
    "importButton" : MessageLookupByLibrary.simpleMessage("导入"),
    "importDecryptError" : MessageLookupByLibrary.simpleMessage("密码无效或数据损坏"),
    "importDesc" : MessageLookupByLibrary.simpleMessage("要导入的项目："),
    "importFileNotFound" : MessageLookupByLibrary.simpleMessage("找不到文件"),
    "importInvalidSwapData" : MessageLookupByLibrary.simpleMessage("交换数据无效。请提供有效的交换状态JSON文件。"),
    "importLink" : MessageLookupByLibrary.simpleMessage("导入"),
    "importLoadDesc" : MessageLookupByLibrary.simpleMessage("请选择要导入的加密文件。"),
    "importLoadSwapDesc" : MessageLookupByLibrary.simpleMessage("请选择要导入的纯文本交换文件。"),
    "importLoading" : MessageLookupByLibrary.simpleMessage("开始"),
    "importPassCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "importPassOk" : MessageLookupByLibrary.simpleMessage("好的"),
    "importPassword" : MessageLookupByLibrary.simpleMessage("密码"),
    "importSingleSwapLink" : MessageLookupByLibrary.simpleMessage("导入单个交换"),
    "importSingleSwapTitle" : MessageLookupByLibrary.simpleMessage("导入交换"),
    "importSomeItemsSkippedWarning" : MessageLookupByLibrary.simpleMessage("已跳过某些项目"),
    "importSuccessTitle" : MessageLookupByLibrary.simpleMessage("已成功导入项目："),
    "importSwapFailed" : MessageLookupByLibrary.simpleMessage("无法导入交换"),
    "importSwapJsonDecodingError" : MessageLookupByLibrary.simpleMessage("解码json文件时出错"),
    "importTitle" : MessageLookupByLibrary.simpleMessage("导入"),
    "infoPasswordDialog" : MessageLookupByLibrary.simpleMessage("使用安全密码，不要将其存储在同一设备上"),
    "infoTrade1" : MessageLookupByLibrary.simpleMessage("無法撤銷交换请求！"),
    "infoTrade2" : MessageLookupByLibrary.simpleMessage("交换最长需要60分钟。不要关闭此应用程序！"),
    "infoWalletPassword" : MessageLookupByLibrary.simpleMessage("安全起见，您必须为加密钱包设置密码。"),
    "insufficientBalanceToPay" : m39,
    "insufficientText" : MessageLookupByLibrary.simpleMessage("此订单最小交易量为"),
    "insufficientTitle" : MessageLookupByLibrary.simpleMessage("交易量不足"),
    "internetRefreshButton" : MessageLookupByLibrary.simpleMessage("刷新"),
    "internetRestored" : MessageLookupByLibrary.simpleMessage("已重新连接互联网"),
    "invalidSwap" : MessageLookupByLibrary.simpleMessage("无法继续交换"),
    "invalidSwapDetailsLink" : MessageLookupByLibrary.simpleMessage("详细信息"),
    "isUnavailable" : m40,
    "japaneseLanguage" : MessageLookupByLibrary.simpleMessage("日文"),
    "language" : MessageLookupByLibrary.simpleMessage("语言"),
    "latestTxs" : MessageLookupByLibrary.simpleMessage("最新交易"),
    "legalTitle" : MessageLookupByLibrary.simpleMessage("合法的"),
    "less" : MessageLookupByLibrary.simpleMessage("较少"),
    "loading" : MessageLookupByLibrary.simpleMessage("載入中"),
    "loadingOrderbook" : MessageLookupByLibrary.simpleMessage("正在加载订单记录"),
    "lockScreen" : MessageLookupByLibrary.simpleMessage("屏幕已锁定"),
    "lockScreenAuth" : MessageLookupByLibrary.simpleMessage("请验证！"),
    "login" : MessageLookupByLibrary.simpleMessage("登录"),
    "logout" : MessageLookupByLibrary.simpleMessage("注销"),
    "logoutOnExit" : MessageLookupByLibrary.simpleMessage("退出时注销"),
    "logoutWarning" : MessageLookupByLibrary.simpleMessage("您确定要立即注销吗？"),
    "logoutsettings" : MessageLookupByLibrary.simpleMessage("注销设置"),
    "longMinutes" : MessageLookupByLibrary.simpleMessage("分钟"),
    "makeAorder" : MessageLookupByLibrary.simpleMessage("下订单"),
    "makerDetailsCancel" : MessageLookupByLibrary.simpleMessage("取消订单"),
    "makerDetailsCreated" : MessageLookupByLibrary.simpleMessage("创建"),
    "makerDetailsFor" : MessageLookupByLibrary.simpleMessage("接收"),
    "makerDetailsId" : MessageLookupByLibrary.simpleMessage("订单ID"),
    "makerDetailsNoSwaps" : MessageLookupByLibrary.simpleMessage("此订单未启动交换"),
    "makerDetailsPrice" : MessageLookupByLibrary.simpleMessage("价格"),
    "makerDetailsSell" : MessageLookupByLibrary.simpleMessage("卖出"),
    "makerDetailsSwaps" : MessageLookupByLibrary.simpleMessage("此订单开始交换"),
    "makerDetailsTitle" : MessageLookupByLibrary.simpleMessage("挂单交易详细信息"),
    "makerOrder" : MessageLookupByLibrary.simpleMessage("挂单交易"),
    "marketplace" : MessageLookupByLibrary.simpleMessage("市场"),
    "marketsChart" : MessageLookupByLibrary.simpleMessage("图表"),
    "marketsDepth" : MessageLookupByLibrary.simpleMessage("交易深度"),
    "marketsNoAsks" : MessageLookupByLibrary.simpleMessage("未找到问题"),
    "marketsNoBids" : MessageLookupByLibrary.simpleMessage("未找到出价"),
    "marketsOrderDetails" : MessageLookupByLibrary.simpleMessage("订单详细信息"),
    "marketsOrderbook" : MessageLookupByLibrary.simpleMessage("订单记录"),
    "marketsPrice" : MessageLookupByLibrary.simpleMessage("价格"),
    "marketsSelectCoins" : MessageLookupByLibrary.simpleMessage("请选择货币"),
    "marketsTab" : MessageLookupByLibrary.simpleMessage("市场"),
    "marketsTitle" : MessageLookupByLibrary.simpleMessage("市场"),
    "matchExportPass" : MessageLookupByLibrary.simpleMessage("密码必须匹配"),
    "matchingCamoChange" : MessageLookupByLibrary.simpleMessage("改变"),
    "matchingCamoPinError" : MessageLookupByLibrary.simpleMessage("您的通用PIN码和伪装PIN码相同。伪装模式将不可用。请更改伪装PIN"),
    "matchingCamoTitle" : MessageLookupByLibrary.simpleMessage("无效PIN"),
    "max" : MessageLookupByLibrary.simpleMessage("最大"),
    "maxOrder" : MessageLookupByLibrary.simpleMessage("最大交易量"),
    "media" : MessageLookupByLibrary.simpleMessage("消息"),
    "mediaBrowse" : MessageLookupByLibrary.simpleMessage("浏览"),
    "mediaBrowseFeed" : MessageLookupByLibrary.simpleMessage("浏览Feed"),
    "mediaBy" : MessageLookupByLibrary.simpleMessage("通过"),
    "mediaNotSavedDescription" : MessageLookupByLibrary.simpleMessage("您没有收藏的文章"),
    "mediaSaved" : MessageLookupByLibrary.simpleMessage("已收藏"),
    "merge" : MessageLookupByLibrary.simpleMessage("合并"),
    "mergedValue" : MessageLookupByLibrary.simpleMessage("合并值"),
    "milliseconds" : MessageLookupByLibrary.simpleMessage("毫秒"),
    "min" : MessageLookupByLibrary.simpleMessage("最小"),
    "minOrder" : MessageLookupByLibrary.simpleMessage("最小交易量"),
    "minValue" : m41,
    "minValueBuy" : m42,
    "minValueOrder" : m43,
    "minValueSell" : m44,
    "minVolumeInput" : m45,
    "minVolumeIsTDH" : MessageLookupByLibrary.simpleMessage("必须低于售出量"),
    "minVolumeTitle" : MessageLookupByLibrary.simpleMessage("所需最小量"),
    "minVolumeToggle" : MessageLookupByLibrary.simpleMessage("使用自定义最小量"),
    "minutes" : MessageLookupByLibrary.simpleMessage("分钟"),
    "mobileDataWarning" : m46,
    "moreTab" : MessageLookupByLibrary.simpleMessage("更多"),
    "multiActivateGas" : m47,
    "multiBaseAmtPlaceholder" : MessageLookupByLibrary.simpleMessage("数量"),
    "multiBasePlaceholder" : MessageLookupByLibrary.simpleMessage("货币"),
    "multiBaseSelectTitle" : MessageLookupByLibrary.simpleMessage("卖出"),
    "multiConfirmCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "multiConfirmConfirm" : MessageLookupByLibrary.simpleMessage("确认"),
    "multiConfirmTitle" : m48,
    "multiCreate" : MessageLookupByLibrary.simpleMessage("创建"),
    "multiCreateOrder" : MessageLookupByLibrary.simpleMessage("订单"),
    "multiCreateOrders" : MessageLookupByLibrary.simpleMessage("订单"),
    "multiEthFee" : MessageLookupByLibrary.simpleMessage("费用"),
    "multiFiatCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "multiFiatDesc" : MessageLookupByLibrary.simpleMessage("请输入要接收的法币数量"),
    "multiFiatFill" : MessageLookupByLibrary.simpleMessage("自动填充"),
    "multiFixErrors" : MessageLookupByLibrary.simpleMessage("请在继续之前修复所有错误"),
    "multiInvalidAmt" : MessageLookupByLibrary.simpleMessage("数量无效"),
    "multiInvalidSellAmt" : MessageLookupByLibrary.simpleMessage("售出量无效"),
    "multiLowGas" : m49,
    "multiLowerThanFee" : m50,
    "multiMaxSellAmt" : MessageLookupByLibrary.simpleMessage("最大售出量为"),
    "multiMinReceiveAmt" : MessageLookupByLibrary.simpleMessage("最小接收量为"),
    "multiMinSellAmt" : MessageLookupByLibrary.simpleMessage("最小售出量为"),
    "multiReceiveTitle" : MessageLookupByLibrary.simpleMessage("接收："),
    "multiSellTitle" : MessageLookupByLibrary.simpleMessage("卖出"),
    "multiTab" : MessageLookupByLibrary.simpleMessage("多个"),
    "multiTableAmt" : MessageLookupByLibrary.simpleMessage("接收量"),
    "multiTablePrice" : MessageLookupByLibrary.simpleMessage("价格/CEX"),
    "networkFee" : MessageLookupByLibrary.simpleMessage("网络费用"),
    "newAccount" : MessageLookupByLibrary.simpleMessage("新帳戶"),
    "newAccountUpper" : MessageLookupByLibrary.simpleMessage("新帳戶"),
    "newValue" : MessageLookupByLibrary.simpleMessage("新价值"),
    "newsFeed" : MessageLookupByLibrary.simpleMessage("Feed新闻"),
    "next" : MessageLookupByLibrary.simpleMessage("继续"),
    "no" : MessageLookupByLibrary.simpleMessage("不"),
    "noArticles" : MessageLookupByLibrary.simpleMessage("没有新闻-请稍后再查看"),
    "noCoinFound" : MessageLookupByLibrary.simpleMessage("未找到货币"),
    "noFunds" : MessageLookupByLibrary.simpleMessage("无基金"),
    "noFundsDetected" : MessageLookupByLibrary.simpleMessage("没有可用基金-请先存入"),
    "noInternet" : MessageLookupByLibrary.simpleMessage("无互联网连接"),
    "noItemsToExport" : MessageLookupByLibrary.simpleMessage("未选择项目"),
    "noItemsToImport" : MessageLookupByLibrary.simpleMessage("未选择项目"),
    "noMatchingOrders" : MessageLookupByLibrary.simpleMessage("无匹配订单"),
    "noOrder" : m51,
    "noOrderAvailable" : MessageLookupByLibrary.simpleMessage("点击创建订单"),
    "noOrders" : MessageLookupByLibrary.simpleMessage("没有订单，请先交易"),
    "noRewardYet" : MessageLookupByLibrary.simpleMessage("没有奖励可领取-请一小时后重试"),
    "noRewards" : MessageLookupByLibrary.simpleMessage("没有奖励可领取"),
    "noSuchCoin" : MessageLookupByLibrary.simpleMessage("没有该货币"),
    "noSwaps" : MessageLookupByLibrary.simpleMessage("没有历史记录"),
    "noTxs" : MessageLookupByLibrary.simpleMessage("没有交易"),
    "nonNumericInput" : MessageLookupByLibrary.simpleMessage("该值必须是数字"),
    "notEnoughGas" : m52,
    "notEnoughtBalanceForFee" : MessageLookupByLibrary.simpleMessage("手续费余额不足-减少交易量"),
    "noteOnOrder" : MessageLookupByLibrary.simpleMessage("备注：不能取消已匹配的订单"),
    "notePlaceholder" : MessageLookupByLibrary.simpleMessage("添加备注"),
    "noteTitle" : MessageLookupByLibrary.simpleMessage("备注"),
    "nothingFound" : MessageLookupByLibrary.simpleMessage("无内容"),
    "notifSwapCompletedText" : m53,
    "notifSwapCompletedTitle" : MessageLookupByLibrary.simpleMessage("交换已完成"),
    "notifSwapFailedText" : m54,
    "notifSwapFailedTitle" : MessageLookupByLibrary.simpleMessage("交换失败"),
    "notifSwapStartedText" : m55,
    "notifSwapStartedTitle" : MessageLookupByLibrary.simpleMessage("已开始新交换"),
    "notifSwapStatusTitle" : MessageLookupByLibrary.simpleMessage("交换状态已更改"),
    "notifSwapTimeoutText" : m56,
    "notifSwapTimeoutTitle" : MessageLookupByLibrary.simpleMessage("交换超时"),
    "notifTxText" : m57,
    "notifTxTitle" : MessageLookupByLibrary.simpleMessage("应记交易"),
    "numberAssets" : m58,
    "okButton" : MessageLookupByLibrary.simpleMessage("好的"),
    "oldLogsDelete" : MessageLookupByLibrary.simpleMessage("删除"),
    "oldLogsTitle" : MessageLookupByLibrary.simpleMessage("历史记录"),
    "oldLogsUsed" : MessageLookupByLibrary.simpleMessage("占用的空间"),
    "openMessage" : MessageLookupByLibrary.simpleMessage("打开错误消息"),
    "orderCancel" : m59,
    "orderCreated" : MessageLookupByLibrary.simpleMessage("订单已创建"),
    "orderCreatedInfo" : MessageLookupByLibrary.simpleMessage("订单已成功创建"),
    "orderDetailsAddress" : MessageLookupByLibrary.simpleMessage("地址"),
    "orderDetailsCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "orderDetailsExpedient" : m60,
    "orderDetailsExpensive" : m61,
    "orderDetailsFor" : MessageLookupByLibrary.simpleMessage("与"),
    "orderDetailsIdentical" : MessageLookupByLibrary.simpleMessage("CEX相同"),
    "orderDetailsMin" : MessageLookupByLibrary.simpleMessage("最小量"),
    "orderDetailsPrice" : MessageLookupByLibrary.simpleMessage("价格"),
    "orderDetailsReceive" : MessageLookupByLibrary.simpleMessage("接收"),
    "orderDetailsSelect" : MessageLookupByLibrary.simpleMessage("选择"),
    "orderDetailsSells" : MessageLookupByLibrary.simpleMessage("卖出"),
    "orderDetailsSettings" : MessageLookupByLibrary.simpleMessage("单击打开详细信息，然后长按选择订购"),
    "orderDetailsSpend" : MessageLookupByLibrary.simpleMessage("花费"),
    "orderDetailsTitle" : MessageLookupByLibrary.simpleMessage("详细信息"),
    "orderFilled" : m62,
    "orderMatched" : MessageLookupByLibrary.simpleMessage("已匹配订单"),
    "orderMatching" : MessageLookupByLibrary.simpleMessage("订单匹配中"),
    "orderTypePartial" : MessageLookupByLibrary.simpleMessage("订单"),
    "orderTypeUnknown" : MessageLookupByLibrary.simpleMessage("未知类型订单"),
    "orders" : MessageLookupByLibrary.simpleMessage("订单"),
    "ordersActive" : MessageLookupByLibrary.simpleMessage("活跃"),
    "ordersHistory" : MessageLookupByLibrary.simpleMessage("历史记录"),
    "ordersTableAmount" : m63,
    "ordersTablePrice" : m64,
    "ordersTableTotal" : m65,
    "overwrite" : MessageLookupByLibrary.simpleMessage("覆盖"),
    "ownOrder" : MessageLookupByLibrary.simpleMessage("这是您个人的订单"),
    "paidFromBalance" : MessageLookupByLibrary.simpleMessage("用余额支付："),
    "paidFromVolume" : MessageLookupByLibrary.simpleMessage("用已接收的交易量支付"),
    "paidWith" : MessageLookupByLibrary.simpleMessage("支付方式："),
    "passwordRequirement" : MessageLookupByLibrary.simpleMessage("密码必须至少包含12个字符，包括一个小写、一个大写和一个特殊符号"),
    "paymentUriDetailsAccept" : MessageLookupByLibrary.simpleMessage("支付"),
    "paymentUriDetailsAcceptQuestion" : MessageLookupByLibrary.simpleMessage("您接受这笔交易吗？"),
    "paymentUriDetailsAddressSpan" : MessageLookupByLibrary.simpleMessage("接收方地址"),
    "paymentUriDetailsAmountSpan" : MessageLookupByLibrary.simpleMessage("数量："),
    "paymentUriDetailsCoinSpan" : MessageLookupByLibrary.simpleMessage("货币："),
    "paymentUriDetailsDeny" : MessageLookupByLibrary.simpleMessage("取消"),
    "paymentUriDetailsTitle" : MessageLookupByLibrary.simpleMessage("已请求的付款"),
    "paymentUriInactiveCoin" : m66,
    "placeOrder" : MessageLookupByLibrary.simpleMessage("下单"),
    "pleaseAddCoin" : MessageLookupByLibrary.simpleMessage("请添加货币"),
    "pleaseRestart" : MessageLookupByLibrary.simpleMessage("请重启应用程序后重试，或按下面的按钮。"),
    "portfolio" : MessageLookupByLibrary.simpleMessage("投资组合"),
    "poweredOnKmd" : MessageLookupByLibrary.simpleMessage("由Komodo支持"),
    "price" : MessageLookupByLibrary.simpleMessage("价格"),
    "privateKey" : MessageLookupByLibrary.simpleMessage("私钥"),
    "privateKeys" : MessageLookupByLibrary.simpleMessage("私钥"),
    "protectionCtrlConfirmations" : MessageLookupByLibrary.simpleMessage("确认"),
    "protectionCtrlCustom" : MessageLookupByLibrary.simpleMessage("使用自定义保护设置"),
    "protectionCtrlOff" : MessageLookupByLibrary.simpleMessage("关闭"),
    "protectionCtrlOn" : MessageLookupByLibrary.simpleMessage("开启"),
    "protectionCtrlWarning" : MessageLookupByLibrary.simpleMessage("警告，此原子交换不受dPoW保护。"),
    "pubkey" : MessageLookupByLibrary.simpleMessage("公钥"),
    "question_1" : MessageLookupByLibrary.simpleMessage("你们会保存我的私钥吗？"),
    "question_10" : m67,
    "question_2" : m68,
    "question_3" : MessageLookupByLibrary.simpleMessage("每次原子交换需要多长时间？"),
    "question_4" : MessageLookupByLibrary.simpleMessage("在交换期间我要保持在线吗"),
    "question_5" : m69,
    "question_6" : MessageLookupByLibrary.simpleMessage("你们会提供用户支持吗？"),
    "question_7" : MessageLookupByLibrary.simpleMessage("你们有地区限制吗？"),
    "question_8" : m70,
    "question_9" : m71,
    "receive" : MessageLookupByLibrary.simpleMessage("接收"),
    "receiveLower" : MessageLookupByLibrary.simpleMessage("接收"),
    "recommendSeedMessage" : MessageLookupByLibrary.simpleMessage("我们建议在线下存档。"),
    "remove" : MessageLookupByLibrary.simpleMessage("停用"),
    "requestedTrade" : MessageLookupByLibrary.simpleMessage("已请求的交易"),
    "reset" : MessageLookupByLibrary.simpleMessage("清除"),
    "resetTitle" : MessageLookupByLibrary.simpleMessage("重置表格"),
    "restoreWallet" : MessageLookupByLibrary.simpleMessage("恢复"),
    "retryActivating" : MessageLookupByLibrary.simpleMessage("正在重试激活所有货币"),
    "retryAll" : MessageLookupByLibrary.simpleMessage("重试激活所有"),
    "rewardsButton" : MessageLookupByLibrary.simpleMessage("领取奖励"),
    "rewardsCancel" : MessageLookupByLibrary.simpleMessage("取消"),
    "rewardsError" : MessageLookupByLibrary.simpleMessage("出现错误。请稍后再试。"),
    "rewardsInProgressLong" : MessageLookupByLibrary.simpleMessage("交易正在进行"),
    "rewardsInProgressShort" : MessageLookupByLibrary.simpleMessage("处理"),
    "rewardsLowAmountLong" : MessageLookupByLibrary.simpleMessage("UTXO金额小于10 KMD"),
    "rewardsLowAmountShort" : MessageLookupByLibrary.simpleMessage("<10KMD"),
    "rewardsOneHourLong" : MessageLookupByLibrary.simpleMessage("还未过去一小时"),
    "rewardsOneHourShort" : MessageLookupByLibrary.simpleMessage("<1小时"),
    "rewardsPopupOk" : MessageLookupByLibrary.simpleMessage("好的"),
    "rewardsPopupTitle" : MessageLookupByLibrary.simpleMessage("奖励状态："),
    "rewardsReadMore" : MessageLookupByLibrary.simpleMessage("阅读有关KMD活跃用户奖励的更多信息"),
    "rewardsReceive" : MessageLookupByLibrary.simpleMessage("接收"),
    "rewardsSuccess" : m72,
    "rewardsTableFiat" : MessageLookupByLibrary.simpleMessage("法币"),
    "rewardsTableRewards" : MessageLookupByLibrary.simpleMessage("奖励，KMD"),
    "rewardsTableStatus" : MessageLookupByLibrary.simpleMessage("状态"),
    "rewardsTableTime" : MessageLookupByLibrary.simpleMessage("剩余时间"),
    "rewardsTableTitle" : MessageLookupByLibrary.simpleMessage("奖励信息"),
    "rewardsTableUXTO" : MessageLookupByLibrary.simpleMessage("UTXO 数量\nKMD"),
    "rewardsTimeDays" : m73,
    "rewardsTimeHours" : m74,
    "rewardsTimeMin" : m75,
    "rewardsTitle" : MessageLookupByLibrary.simpleMessage("奖励信息"),
    "russianLanguage" : MessageLookupByLibrary.simpleMessage("俄语"),
    "saveMerged" : MessageLookupByLibrary.simpleMessage("保存合并"),
    "searchFilterCoin" : MessageLookupByLibrary.simpleMessage("搜索货币"),
    "searchFilterSubtitleAVX" : MessageLookupByLibrary.simpleMessage("选择所有Avax代币"),
    "searchFilterSubtitleBEP" : MessageLookupByLibrary.simpleMessage("选择所有BEP代币"),
    "searchFilterSubtitleERC" : MessageLookupByLibrary.simpleMessage("选择所有ERC代币"),
    "searchFilterSubtitleETC" : MessageLookupByLibrary.simpleMessage("选择所有ETC代币"),
    "searchFilterSubtitleFTM" : MessageLookupByLibrary.simpleMessage("选择所有Fantom代币"),
    "searchFilterSubtitleHCO" : MessageLookupByLibrary.simpleMessage("选择所有HecoChain代币"),
    "searchFilterSubtitleHRC" : MessageLookupByLibrary.simpleMessage("选择所有Harmony代币"),
    "searchFilterSubtitleKRC" : MessageLookupByLibrary.simpleMessage("选择所有Kucoin代币"),
    "searchFilterSubtitleMVR" : MessageLookupByLibrary.simpleMessage("选择所有Moonriver代币"),
    "searchFilterSubtitlePLG" : MessageLookupByLibrary.simpleMessage("选择所有Polygon代币"),
    "searchFilterSubtitleQRC" : MessageLookupByLibrary.simpleMessage("选择所有QRC代币"),
    "searchFilterSubtitleSBCH" : MessageLookupByLibrary.simpleMessage("选择所有SmartBCH代币"),
    "searchFilterSubtitleSmartChain" : MessageLookupByLibrary.simpleMessage("选择所有智能链"),
    "searchFilterSubtitleTestCoins" : MessageLookupByLibrary.simpleMessage("选择所有测试资产"),
    "searchFilterSubtitleUBQ" : MessageLookupByLibrary.simpleMessage("选择所有Ubiq货币"),
    "searchFilterSubtitleutxo" : MessageLookupByLibrary.simpleMessage("选择所有UTXO货币"),
    "searchForTicker" : MessageLookupByLibrary.simpleMessage("搜索货币代码"),
    "seconds" : MessageLookupByLibrary.simpleMessage("秒"),
    "security" : MessageLookupByLibrary.simpleMessage("证券"),
    "seeOrders" : m76,
    "seeTxHistory" : MessageLookupByLibrary.simpleMessage("查看交易记录"),
    "seedPhrase" : MessageLookupByLibrary.simpleMessage("助记词"),
    "seedPhraseTitle" : MessageLookupByLibrary.simpleMessage("您的新助記詞"),
    "selectCoin" : MessageLookupByLibrary.simpleMessage("选择货币"),
    "selectCoinInfo" : MessageLookupByLibrary.simpleMessage("选择您想要添加到投资组合的货币"),
    "selectCoinTitle" : MessageLookupByLibrary.simpleMessage("激活货币："),
    "selectCoinToBuy" : MessageLookupByLibrary.simpleMessage("选择您想买入的货币"),
    "selectCoinToSell" : MessageLookupByLibrary.simpleMessage("选择您想卖出的货币"),
    "selectFileImport" : MessageLookupByLibrary.simpleMessage("选择文件"),
    "selectLanguage" : MessageLookupByLibrary.simpleMessage("选择语言"),
    "selectPaymentMethod" : MessageLookupByLibrary.simpleMessage("选择您的支付方式"),
    "selectedOrder" : MessageLookupByLibrary.simpleMessage("选择订单"),
    "sell" : MessageLookupByLibrary.simpleMessage("卖出"),
    "sellTestCoinWarning" : MessageLookupByLibrary.simpleMessage("警告，您正在卖出没有实际价值的测试币!"),
    "send" : MessageLookupByLibrary.simpleMessage("发送"),
    "setUpPassword" : MessageLookupByLibrary.simpleMessage("创建密码"),
    "settingDialogSpan1" : MessageLookupByLibrary.simpleMessage("您确定要删除"),
    "settingDialogSpan2" : MessageLookupByLibrary.simpleMessage("钱包吗"),
    "settingDialogSpan3" : MessageLookupByLibrary.simpleMessage("如果是，请确认您已"),
    "settingDialogSpan4" : MessageLookupByLibrary.simpleMessage("记下助记词"),
    "settingDialogSpan5" : MessageLookupByLibrary.simpleMessage("以便在将来恢复您的钱包"),
    "settingLanguageTitle" : MessageLookupByLibrary.simpleMessage("语言"),
    "settings" : MessageLookupByLibrary.simpleMessage("设置"),
    "share" : MessageLookupByLibrary.simpleMessage("分享"),
    "shareAddress" : m77,
    "showDetails" : MessageLookupByLibrary.simpleMessage("显示详细信息"),
    "showMyOrders" : MessageLookupByLibrary.simpleMessage("显示我的订单"),
    "signInWithPassword" : MessageLookupByLibrary.simpleMessage("使用密码登录"),
    "signInWithSeedPhrase" : MessageLookupByLibrary.simpleMessage("忘记密码？用助记词恢复钱包"),
    "simple" : MessageLookupByLibrary.simpleMessage("简单"),
    "simpleTradeActivate" : MessageLookupByLibrary.simpleMessage("激活"),
    "simpleTradeBuyHint" : m78,
    "simpleTradeBuyTitle" : MessageLookupByLibrary.simpleMessage("买入"),
    "simpleTradeClose" : MessageLookupByLibrary.simpleMessage("关闭"),
    "simpleTradeMaxActiveCoins" : m79,
    "simpleTradeNotActive" : m80,
    "simpleTradeRecieve" : MessageLookupByLibrary.simpleMessage("接收"),
    "simpleTradeSellHint" : m81,
    "simpleTradeSellTitle" : MessageLookupByLibrary.simpleMessage("卖出"),
    "simpleTradeSend" : MessageLookupByLibrary.simpleMessage("发送"),
    "simpleTradeShowLess" : MessageLookupByLibrary.simpleMessage("收起"),
    "simpleTradeShowMore" : MessageLookupByLibrary.simpleMessage("显示更多"),
    "simpleTradeUnableActivate" : m82,
    "skip" : MessageLookupByLibrary.simpleMessage("跳过"),
    "snackbarDismiss" : MessageLookupByLibrary.simpleMessage("不予考虑"),
    "soundCantPlayThatMsg" : m83,
    "soundPlayedWhen" : m84,
    "soundSettingsLink" : MessageLookupByLibrary.simpleMessage("声音"),
    "soundSettingsTitle" : MessageLookupByLibrary.simpleMessage("声音设置"),
    "soundsDialogTitle" : MessageLookupByLibrary.simpleMessage("声音"),
    "soundsDoNotShowAgain" : MessageLookupByLibrary.simpleMessage("已知晓，不再显示"),
    "soundsExplanation" : MessageLookupByLibrary.simpleMessage("交换时，如果您有一个活跃的挂单交易，会收到声音提醒。\n原子交换协议要求参与者在线才能成功交易，声音通知可以帮助实现这一点。"),
    "soundsNote" : MessageLookupByLibrary.simpleMessage("请注意，您可以在应用程序设置中设置自定义声音。"),
    "spanishLanguage" : MessageLookupByLibrary.simpleMessage("西班牙语"),
    "step" : MessageLookupByLibrary.simpleMessage("步骤"),
    "success" : MessageLookupByLibrary.simpleMessage("成功"),
    "support" : MessageLookupByLibrary.simpleMessage("支持"),
    "supportLinksDesc" : m85,
    "swap" : MessageLookupByLibrary.simpleMessage("交换"),
    "swapCurrent" : MessageLookupByLibrary.simpleMessage("现状"),
    "swapDetailTitle" : MessageLookupByLibrary.simpleMessage("确认兑换细节"),
    "swapEstimated" : MessageLookupByLibrary.simpleMessage("预估"),
    "swapFailed" : MessageLookupByLibrary.simpleMessage("交换失败"),
    "swapGasActivate" : m86,
    "swapGasAmount" : m87,
    "swapGasAmountRequired" : m88,
    "swapOngoing" : MessageLookupByLibrary.simpleMessage("正在交换"),
    "swapProgress" : MessageLookupByLibrary.simpleMessage("进度详情"),
    "swapStarted" : MessageLookupByLibrary.simpleMessage("已开始"),
    "swapSucceful" : MessageLookupByLibrary.simpleMessage("交换成功"),
    "swapTotal" : MessageLookupByLibrary.simpleMessage("总共"),
    "swapUUID" : MessageLookupByLibrary.simpleMessage("UUID交换"),
    "switchTheme" : MessageLookupByLibrary.simpleMessage("切换主题"),
    "tagAVX20" : MessageLookupByLibrary.simpleMessage("AVX20"),
    "tagBEP20" : MessageLookupByLibrary.simpleMessage("BEP20"),
    "tagERC20" : MessageLookupByLibrary.simpleMessage("ERC20"),
    "tagETC" : MessageLookupByLibrary.simpleMessage("ETC"),
    "tagFTM20" : MessageLookupByLibrary.simpleMessage("FTM20"),
    "tagHCO20" : MessageLookupByLibrary.simpleMessage("HCO20"),
    "tagHRC20" : MessageLookupByLibrary.simpleMessage("HRC20"),
    "tagKMD" : MessageLookupByLibrary.simpleMessage("KMD"),
    "tagKRC20" : MessageLookupByLibrary.simpleMessage("KRC20"),
    "tagMVR20" : MessageLookupByLibrary.simpleMessage("MVR20"),
    "tagPLG20" : MessageLookupByLibrary.simpleMessage("PLG20"),
    "tagQRC20" : MessageLookupByLibrary.simpleMessage("QRC20"),
    "tagSBCH" : MessageLookupByLibrary.simpleMessage("SBCH"),
    "tagUBQ" : MessageLookupByLibrary.simpleMessage("UBQ"),
    "takerOrder" : MessageLookupByLibrary.simpleMessage("吃单交易"),
    "timeOut" : MessageLookupByLibrary.simpleMessage("超时"),
    "titleCreatePassword" : MessageLookupByLibrary.simpleMessage("创建密码"),
    "titleCurrentAsk" : MessageLookupByLibrary.simpleMessage("选择订单"),
    "to" : MessageLookupByLibrary.simpleMessage("至"),
    "toAddress" : MessageLookupByLibrary.simpleMessage("接收地址"),
    "tooManyAssetsEnabledSpan1" : MessageLookupByLibrary.simpleMessage("您已"),
    "tooManyAssetsEnabledSpan2" : MessageLookupByLibrary.simpleMessage("启用资产。启用资产上限为"),
    "tooManyAssetsEnabledSpan3" : MessageLookupByLibrary.simpleMessage("请在启用新资产前停用一些资产"),
    "tooManyAssetsEnabledTitle" : MessageLookupByLibrary.simpleMessage("已启用的资产太多"),
    "totalFees" : MessageLookupByLibrary.simpleMessage("总费用"),
    "trade" : MessageLookupByLibrary.simpleMessage("交易"),
    "tradeCompleted" : MessageLookupByLibrary.simpleMessage("交换完成！"),
    "tradeDetail" : MessageLookupByLibrary.simpleMessage("交易详情"),
    "tradePreimageError" : MessageLookupByLibrary.simpleMessage("无法计算交易费用"),
    "tradingFee" : MessageLookupByLibrary.simpleMessage("交易费用："),
    "tradingMode" : MessageLookupByLibrary.simpleMessage("交易模式："),
    "traditionalChinese" : MessageLookupByLibrary.simpleMessage("传统的"),
    "tryRestarting" : MessageLookupByLibrary.simpleMessage("如果还是有一些货币未被激活，请尝试重启应用程序。"),
    "turkishLanguage" : MessageLookupByLibrary.simpleMessage("土耳其语"),
    "txBlock" : MessageLookupByLibrary.simpleMessage("区块"),
    "txConfirmations" : MessageLookupByLibrary.simpleMessage("确认"),
    "txConfirmed" : MessageLookupByLibrary.simpleMessage("已确认"),
    "txFee" : MessageLookupByLibrary.simpleMessage("费用"),
    "txFeeTitle" : MessageLookupByLibrary.simpleMessage("交易费用"),
    "txHash" : MessageLookupByLibrary.simpleMessage("交易ID"),
    "txLimitExceeded" : MessageLookupByLibrary.simpleMessage("请求过多。超出交易历史请求限制。请稍后重试"),
    "txNotConfirmed" : MessageLookupByLibrary.simpleMessage("未确认"),
    "txleft" : m89,
    "unlock" : MessageLookupByLibrary.simpleMessage("解锁"),
    "unlockFunds" : MessageLookupByLibrary.simpleMessage("解锁基金"),
    "unlockSuccess" : m90,
    "unspendable" : MessageLookupByLibrary.simpleMessage("不可交易"),
    "updatesAvailable" : MessageLookupByLibrary.simpleMessage("已有新版本"),
    "updatesChecking" : MessageLookupByLibrary.simpleMessage("正在检查更新"),
    "updatesCurrentVersion" : m91,
    "updatesNotifAvailable" : MessageLookupByLibrary.simpleMessage("已有新版本。请更新。"),
    "updatesNotifAvailableVersion" : m92,
    "updatesNotifTitle" : MessageLookupByLibrary.simpleMessage("可更新"),
    "updatesSkip" : MessageLookupByLibrary.simpleMessage("暂时跳过"),
    "updatesTitle" : m93,
    "updatesUpToDate" : MessageLookupByLibrary.simpleMessage("准备更新"),
    "updatesUpdate" : MessageLookupByLibrary.simpleMessage("已更新"),
    "uriInsufficientBalanceSpan1" : MessageLookupByLibrary.simpleMessage("余额不足，无法扫描"),
    "uriInsufficientBalanceSpan2" : MessageLookupByLibrary.simpleMessage("付款请求。"),
    "uriInsufficientBalanceTitle" : MessageLookupByLibrary.simpleMessage("余额不足"),
    "value" : MessageLookupByLibrary.simpleMessage("价值"),
    "version" : MessageLookupByLibrary.simpleMessage("版本"),
    "viewInExplorerButton" : MessageLookupByLibrary.simpleMessage("资源管理器"),
    "viewSeedAndKeys" : MessageLookupByLibrary.simpleMessage("助记词和私钥"),
    "volumes" : MessageLookupByLibrary.simpleMessage("交易量"),
    "walletInUse" : MessageLookupByLibrary.simpleMessage("钱包名称已被使用"),
    "walletMaxChar" : MessageLookupByLibrary.simpleMessage("钱包名称最多40个字符"),
    "walletOnly" : MessageLookupByLibrary.simpleMessage("仅钱包"),
    "warning" : MessageLookupByLibrary.simpleMessage("警告"),
    "warningOkBtn" : MessageLookupByLibrary.simpleMessage("好的"),
    "warningShareLogs" : MessageLookupByLibrary.simpleMessage("警告-在特殊情况下，此登录数据包含敏感信息，可用于消费交换失败的货币！"),
    "weFailedTo" : m94,
    "weFailedToActivate" : m95,
    "welcomeInfo" : m96,
    "welcomeLetSetUp" : MessageLookupByLibrary.simpleMessage("让我们开始吧"),
    "welcomeTitle" : MessageLookupByLibrary.simpleMessage("欢迎"),
    "welcomeWallet" : MessageLookupByLibrary.simpleMessage("钱包"),
    "willBeRedirected" : MessageLookupByLibrary.simpleMessage("完成后，您将跳转至投资组合页面"),
    "withdraw" : MessageLookupByLibrary.simpleMessage("提取"),
    "withdrawCameraAccessText" : m97,
    "withdrawCameraAccessTitle" : MessageLookupByLibrary.simpleMessage("被拒绝使用"),
    "withdrawConfirm" : MessageLookupByLibrary.simpleMessage("确认提取"),
    "withdrawConfirmError" : MessageLookupByLibrary.simpleMessage("出现错误。请稍后重试。"),
    "withdrawValue" : m98,
    "wrongCoinSpan1" : MessageLookupByLibrary.simpleMessage("您正在尝试扫描付款二维码"),
    "wrongCoinSpan2" : MessageLookupByLibrary.simpleMessage("但您在"),
    "wrongCoinSpan3" : MessageLookupByLibrary.simpleMessage("提取页面"),
    "wrongCoinTitle" : MessageLookupByLibrary.simpleMessage("错误货币"),
    "wrongPassword" : MessageLookupByLibrary.simpleMessage("密码不匹配。请重试"),
    "yes" : MessageLookupByLibrary.simpleMessage("对"),
    "you have a fresh order that is trying to match with an existing order" : MessageLookupByLibrary.simpleMessage("您有一个新订单正在尝试与现有订单匹配"),
    "you have an active swap in progress" : MessageLookupByLibrary.simpleMessage("您有一个正在进行的活跃交换"),
    "you have an order that new orders can match with" : MessageLookupByLibrary.simpleMessage("你有一个新订单可以匹配的订单"),
    "youAreSending" : MessageLookupByLibrary.simpleMessage("您正在发送："),
    "youWillReceiveClaim" : m99,
    "youWillReceived" : MessageLookupByLibrary.simpleMessage("您将收到："),
    "yourWallet" : MessageLookupByLibrary.simpleMessage("您的钱包")
  };
}
