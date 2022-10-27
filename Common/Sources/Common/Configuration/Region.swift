import Foundation

public enum Region: String, Hashable, CaseIterable {
    case AF
    case AL
    case DZ
    case AS
    case AD
    case AO
    case AI
    case AG
    case AR
    case AM
    case AW
    case AU
    case AT
    case AZ
    case BS
    case BH
    case BD
    case BB
    case BY
    case BE
    case BZ
    case BJ
    case BM
    case BT
    case BO
    case BA
    case BW
    case BR
    case BN
    case BG
    case BF
    case BI
    case KH
    case CM
    case CA
    case CV
    case CF
    case TD
    case CL
    case CN
    case CO
    case KM
    case CG
    case CR
    case HR
    case CU
    case CY
    case CZ
    case DK
    case EC
    case EG
    case SV
    case GQ
    case ER
    case EE
    case ET
    case FJ
    case FI
    case FR
    case GF
    case PF
    case GA
    case GM
    case GE
    case DE
    case GH
    case GI
    case GR
    case GL
    case GT
    case GY
    case HT
    case VA
    case HN
    case HK
    case HU
    case IS
    case IN
    case ID
    case IR
    case IQ
    case IE
    case IT
    case JM
    case JP
    case JO
    case KZ
    case KE
    case KR
    case KW
    case KG
    case LV
    case LB
    case LS
    case LR
    case LI
    case LT
    case LU
    case MO
    case MY
    case ML
    case MT
    case MU
    case MX
    case FM
    case MD
    case MC
    case MN
    case ME
    case MS
    case MA
    case MZ
    case NP
    case NL
    case NC
    case NZ
    case NI
    case NU
    case NO
    case OM
    case PK
    case PW
    case PA
    case PG
    case PY
    case PE
    case PH
    case PL
    case PT
    case PR
    case QA
    case RO
    case RW
    case WS
    case SM
    case SA
    case SN
    case RS
    case SC
    case SL
    case SG
    case SK
    case SI
    case SO
    case ZA
    case ES
    case LK
    case SD
    case SR
    case SZ
    case SE
    case CH
    case TW
    case TJ
    case TZ
    case TH
    case TL
    case TG
    case TK
    case TO
    case TT
    case TN
    case TR
    case TM
    case TV
    case UG
    case UA
    case AE
    case GB
    case US
    case UY
    case UZ
    case VU
    case VE
    case VN
    case WF
    case YE
    case ZM
    case ZW

    public static var `default`: Region { .GE }
}

extension Region {
    public var phoneNumberCode: String {
        switch self {
        case .AF:
            return "+93"
        case .AL:
            return "+355"
        case .DZ:
            return "+213"
        case .AS:
            return "+1684"
        case .AD:
            return "+376"
        case .AO:
            return "+244"
        case .AI:
            return "+1264"
        case .AG:
            return "+1268"
        case .AR:
            return "+54"
        case .AM:
            return "+374"
        case .AW:
            return "+297"
        case .AU:
            return "+61"
        case .AT:
            return "+43"
        case .AZ:
            return "+994"
        case .BS:
            return "+1242"
        case .BH:
            return "+973"
        case .BD:
            return "+880"
        case .BB:
            return "+1246"
        case .BY:
            return "+375"
        case .BE:
            return "+32"
        case .BZ:
            return "+501"
        case .BJ:
            return "+229"
        case .BM:
            return "+1441"
        case .BT:
            return "+975"
        case .BO:
            return "+591"
        case .BA:
            return "+387"
        case .BW:
            return "+267"
        case .BR:
            return "+55"
        case .BN:
            return "+673"
        case .BG:
            return "+359"
        case .BF:
            return "+226"
        case .BI:
            return "+257"
        case .KH:
            return "+855"
        case .CM:
            return "+237"
        case .CA:
            return "+1"
        case .CV:
            return "+238"
        case .CF:
            return "+236"
        case .TD:
            return "+235"
        case .CL:
            return "+56"
        case .CN:
            return "+86"
        case .CO:
            return "+57"
        case .KM:
            return "+269"
        case .CG:
            return "+242"
        case .CR:
            return "+506"
        case .HR:
            return "+385"
        case .CU:
            return "+53"
        case .CY:
            return "+357"
        case .CZ:
            return "+420"
        case .DK:
            return "+45"
        case .EC:
            return "+593"
        case .EG:
            return "+20"
        case .SV:
            return "+503"
        case .GQ:
            return "+240"
        case .ER:
            return "+291"
        case .EE:
            return "+372"
        case .ET:
            return "+251"
        case .FJ:
            return "+679"
        case .FI:
            return "+358"
        case .FR:
            return "+33"
        case .GF:
            return "+594"
        case .PF:
            return "+689"
        case .GA:
            return "+241"
        case .GM:
            return "+220"
        case .GE:
            return "+995"
        case .DE:
            return "+49"
        case .GH:
            return "+233"
        case .GI:
            return "+350"
        case .GR:
            return "+30"
        case .GL:
            return "+299"
        case .GT:
            return "+502"
        case .GY:
            return "+592"
        case .HT:
            return "+509"
        case .VA:
            return "+379"
        case .HN:
            return "+504"
        case .HK:
            return "+852"
        case .HU:
            return "+36"
        case .IS:
            return "+354"
        case .IN:
            return "+91"
        case .ID:
            return "+62"
        case .IR:
            return "+98"
        case .IQ:
            return "+964"
        case .IE:
            return "+353"
        case .IT:
            return "+39"
        case .JM:
            return "+1876"
        case .JP:
            return "+81"
        case .JO:
            return "+962"
        case .KZ:
            return "+7"
        case .KE:
            return "+254"
        case .KR:
            return "+82"
        case .KW:
            return "+965"
        case .KG:
            return "+996"
        case .LV:
            return "+371"
        case .LB:
            return "+961"
        case .LS:
            return "+266"
        case .LR:
            return "+231"
        case .LI:
            return "+423"
        case .LT:
            return "+370"
        case .LU:
            return "+352"
        case .MO:
            return "+853"
        case .MY:
            return "+60"
        case .ML:
            return "+223"
        case .MT:
            return "+356"
        case .MU:
            return "+230"
        case .MX:
            return "+52"
        case .FM:
            return "+691"
        case .MD:
            return "+373"
        case .MC:
            return "+377"
        case .MN:
            return "+976"
        case .ME:
            return "+382"
        case .MS:
            return "+1664"
        case .MA:
            return "+212"
        case .MZ:
            return "+258"
        case .NP:
            return "+977"
        case .NL:
            return "+31"
        case .NC:
            return "+687"
        case .NZ:
            return "+64"
        case .NI:
            return "+505"
        case .NU:
            return "+683"
        case .NO:
            return "+47"
        case .OM:
            return "+968"
        case .PK:
            return "+92"
        case .PW:
            return "+680"
        case .PA:
            return "+507"
        case .PG:
            return "+675"
        case .PY:
            return "+595"
        case .PE:
            return "+51"
        case .PH:
            return "+63"
        case .PL:
            return "+48"
        case .PT:
            return "+351"
        case .PR:
            return "+1939"
        case .QA:
            return "+974"
        case .RO:
            return "+40"
        case .RW:
            return "+250"
        case .WS:
            return "+685"
        case .SM:
            return "+378"
        case .SA:
            return "+966"
        case .SN:
            return "+221"
        case .RS:
            return "+381"
        case .SC:
            return "+248"
        case .SL:
            return "+232"
        case .SG:
            return "+65"
        case .SK:
            return "+421"
        case .SI:
            return "+386"
        case .SO:
            return "+252"
        case .ZA:
            return "+27"
        case .ES:
            return "+34"
        case .LK:
            return "+94"
        case .SD:
            return "+249"
        case .SR:
            return "+597"
        case .SZ:
            return "+268"
        case .SE:
            return "+46"
        case .CH:
            return "+41"
        case .TW:
            return "+886"
        case .TJ:
            return "+992"
        case .TZ:
            return "+255"
        case .TH:
            return "+66"
        case .TL:
            return "+670"
        case .TG:
            return "+228"
        case .TK:
            return "+690"
        case .TO:
            return "+676"
        case .TT:
            return "+1868"
        case .TN:
            return "+216"
        case .TR:
            return "+90"
        case .TM:
            return "+993"
        case .TV:
            return "+688"
        case .UG:
            return "+256"
        case .UA:
            return "+380"
        case .AE:
            return "+971"
        case .GB:
            return "+44"
        case .US:
            return "+1"
        case .UY:
            return "+598"
        case .UZ:
            return "+998"
        case .VU:
            return "+678"
        case .VE:
            return "+58"
        case .VN:
            return "+84"
        case .WF:
            return "+681"
        case .YE:
            return "+967"
        case .ZM:
            return "+260"
        case .ZW:
            return "+263"
        }
    }

    public var phoneNumberDigitsCount: [Int] {
        switch self {
        case .AF:
            return [9]
        case .AL:
            return Array(3...9)
        case .DZ:
            return [8, 9]
        case .AS:
            return [7]
        case .AD:
            return [6, 8, 9]
        case .AO:
            return [9]
        case .AI:
            return [7]
        case .AG:
            return [7]
        case .AR:
            return [10]
        case .AM:
            return [8]
        case .AW:
            return [7]
        case .AU:
            return Array(5...15)
        case .AT:
            return Array(4...13)
        case .AZ:
            return [8, 9]
        case .BS:
            return [7]
        case .BH:
            return [8]
        case .BD:
            return Array(6...10)
        case .BB:
            return [7]
        case .BY:
            return [9]
        case .BE:
            return [8, 9]
        case .BZ:
            return [7]
        case .BJ:
            return [8]
        case .BM:
            return [7]
        case .BT:
            return [7, 8]
        case .BO:
            return [8]
        case .BA:
            return [8]
        case .BW:
            return [7, 8]
        case .BR:
            return [10]
        case .BN:
            return [7]
        case .BG:
            return [7, 8, 9]
        case .BF:
            return [8]
        case .BI:
            return [8]
        case .KH:
            return [8]
        case .CM:
            return [8]
        case .CA:
            return [10]
        case .CV:
            return [7]
        case .CF:
            return [8]
        case .TD:
            return [8]
        case .CL:
            return [8, 9]
        case .CN:
            return Array(5...12)
        case .CO:
            return [8, 10]
        case .KM:
            return [7]
        case .CG:
            return [9]
        case .CR:
            return [8]
        case .HR:
            return Array(8...12)
        case .CU:
            return [6, 7, 8]
        case .CY:
            return [8, 11]
        case .CZ:
            return Array(4...12)
        case .DK:
            return [8]
        case .EC:
            return [8]
        case .EG:
            return [7, 8, 9]
        case .SV:
            return [7, 8, 11]
        case .GQ:
            return [9]
        case .ER:
            return [7]
        case .EE:
            return Array(7...10)
        case .ET:
            return [9]
        case .FJ:
            return [7]
        case .FI:
            return Array(5...12)
        case .FR:
            return [9]
        case .GF:
            return [9]
        case .PF:
            return [6]
        case .GA:
            return [6, 7]
        case .GM:
            return [7]
        case .GE:
            return [9]
        case .DE:
            return Array(6...13)
        case .GH:
            return Array(5...9)
        case .GI:
            return [8]
        case .GR:
            return [10]
        case .GL:
            return [6]
        case .GT:
            return [8]
        case .GY:
            return [7]
        case .HT:
            return [8]
        case .VA:
            return [8]
        case .HN:
            return [8]
        case .HK:
            return [4, 8, 9]
        case .HU:
            return [8, 9]
        case .IS:
            return [7, 9]
        case .IN:
            return Array(7...10)
        case .ID:
            return Array(5...10)
        case .IR:
            return Array(6...10)
        case .IQ:
            return [8, 9, 10]
        case .IE:
            return Array(7...11)
        case .IT:
            return [11]
        case .JM:
            return [7]
        case .JP:
            return Array(5...13)
        case .JO:
            return Array(5...9)
        case .KZ:
            return [10]
        case .KE:
            return Array(6...10)
        case .KR:
            return Array(8...11)
        case .KW:
            return [7, 8]
        case .KG:
            return [9]
        case .LV:
            return [7, 8]
        case .LB:
            return [7, 8]
        case .LS:
            return [8]
        case .LR:
            return [7, 8]
        case .LI:
            return [7, 8, 9]
        case .LT:
            return [8]
        case .LU:
            return Array(4...11)
        case .MO:
            return [7, 8]
        case .MY:
            return [7, 8, 9]
        case .ML:
            return [8]
        case .MT:
            return [8]
        case .MU:
            return [7]
        case .MX:
            return [10]
        case .FM:
            return [7]
        case .MD:
            return [8]
        case .MC:
            return Array(5...9)
        case .MN:
            return [7, 8]
        case .ME:
            return Array(4...12)
        case .MS:
            return [7]
        case .MA:
            return [9]
        case .MZ:
            return [8, 9]
        case .NP:
            return [8, 9]
        case .NL:
            return [9]
        case .NC:
            return [6]
        case .NZ:
            return Array(3...10)
        case .NI:
            return [8]
        case .NU:
            return [4]
        case .NO:
            return [5, 8]
        case .OM:
            return [7, 8]
        case .PK:
            return Array(8...11)
        case .PW:
            return [7]
        case .PA:
            return [7, 8]
        case .PG:
            return Array(4...11)
        case .PY:
            return Array(5...9)
        case .PE:
            return Array(8...11)
        case .PH:
            return Array(8...10)
        case .PL:
            return Array(6...9)
        case .PT:
            return [9, 11]
        case .PR:
            return [7]
        case .QA:
            return Array(3...8)
        case .RO:
            return [9]
        case .RW:
            return [9]
        case .WS:
            return Array(3...7)
        case .SM:
            return Array(6...10)
        case .SA:
            return [8, 9]
        case .SN:
            return [9]
        case .RS:
            return Array(4...12)
        case .SC:
            return [7]
        case .SL:
            return [8]
        case .SG:
            return Array(8...12)
        case .SK:
            return Array(4...9)
        case .SI:
            return [8]
        case .SO:
            return Array(5...8)
        case .ZA:
            return [9]
        case .ES:
            return [9]
        case .LK:
            return [9]
        case .SD:
            return [9]
        case .SR:
            return [6, 7]
        case .SZ:
            return [7, 8]
        case .SE:
            return Array(7...13)
        case .CH:
            return Array(4...12)
        case .TW:
            return [8, 9]
        case .TJ:
            return [9]
        case .TZ:
            return [9]
        case .TH:
            return [8, 9]
        case .TL:
            return [7]
        case .TG:
            return [8]
        case .TK:
            return [4]
        case .TO:
            return [5, 7]
        case .TT:
            return [7]
        case .TN:
            return [8]
        case .TR:
            return [10]
        case .TM:
            return [8]
        case .TV:
            return [5, 6]
        case .UG:
            return [9]
        case .UA:
            return [9]
        case .AE:
            return [8, 9]
        case .GB:
            return Array(7...10)
        case .US:
            return [10]
        case .UY:
            return Array(4...11)
        case .UZ:
            return [9]
        case .VU:
            return [5, 7]
        case .VE:
            return [10]
        case .VN:
            return Array(7...10)
        case .WF:
            return [6]
        case .YE:
            return Array(6...9)
        case .ZM:
            return [9]
        case .ZW:
            return Array(5...10)
        }
    }
}
