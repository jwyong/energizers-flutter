//===== REGISTRATION
// get list of all uplines for registration search
import 'package:energizers/home/history_tab/HistoryTab.dart';
import 'package:energizers/home/settings_tab/SettingsTab.dart';
import 'package:flutter/material.dart';

//===== REGISTRATION
// get uplines in Reg1
const String getUplines = r'''
  query{
  searchUser{
    name,
    UserMembership {
        membership_code
        membership_id
    }
  }
}
''';

// register
String mutateRegister = r'''
  mutation registerUser($uplineCode: String!, $uplineId: String!, $userType: String!, $email: String!, 
  $nric: String!, $phone: String!, $userName: String!, $pword: String!, $address: String!, 
  $postcode: String!, $city: String!, $state: String!, $country: String!, $compName: String!, 
  $compRegNo: String!, $compAddress: String!, $compPostcode: String!, $compCity: String!, 
  $compState: String!, $compCountry: String!, $compPhone: String!, $bankName: String!, $bankAccNo: String!){
 registerUser(input: {
   regInfo: {
     uplineCode: $uplineCode,
     uplineId: $uplineId,
     userType: $userType,
     email: $email,
     nric: $nric,
     phone_num: $phone,
     username: $userName,
     pass: $pword
   },
   userInfo:{
     address: $address,
     postcode: $postcode,
     city: $city,
     state:$state,
     country:$country
   },
   companyInfo: {
     name: $compName,
     reg_no: $compRegNo,
     address: $compAddress,
     postcode: $compPostcode,
     city:$compCity,
     state:$compState,
     country:$compCountry,
     phone_num: $compPhone
   },
   bankInfo: {
     name: $bankName,
     account_no:$bankAccNo
   }
 })
}
''';

// login
String mutateLogin = r'''
 mutation loginUser($email: String!, $pass: String!){
 loginUser(
  email: $email
  pass: $pass
  ) {
    name
    OauthAccessToken{
      access_token_id
    }
    UserMembership {
      user_type_id
    }
  }
}
''';

// forgot pword
String mutateForgotPword = r'''
 mutation resetPasswordRequest($email: String!){
 resetPasswordRequest(
  email: $email
  )
}
''';

// verify reset code
String queryVeriResetPword = r'''
 query verifyResetPasswordCode($email: String!, $code: String!){
 verifyResetPasswordCode(
  email: $email
  code: $code
  )
}
''';

// reset pword
String mutateResetPword = r'''
 mutation changePassword($password: String!){
 changePassword(
  password: $password
  )
}
''';


//===== HOME TABS
// get cp and vp in drawer
const String queryDrawer = r'''
 query{
 User{
   UserMembership {
      membership_code
      membership_id
   }
   UserTransactions{
     cp_point_earned
     vp_point_earned
   }
 }
}
''';

//===== QR Tab
// post scanned qr
String queryCheckQR = r'''
 query checkQr($qrCode: String!){
 checkQr(
  qrCode: $qrCode
  )
}
''';

// post qr form after scan qr succeed
String mutateClaimQR = r'''
 mutation claimQr($qrCode: String!, $carNo: String!, $carYear: String!, 
 $recon: Int!, $overhaul: Int!){
 claimQr(info: {
  qrCode: $qrCode
  carNo: $carNo
  carYear: $carYear
  recon: $recon
  overhaul: $overhaul
  })
}
''';

//===== HistoryTab
const String queryQrHistory = r'''
 query{
 User{
   UserTransactions{
     transaction_id
     cp_point_earned
     vp_point_earned
     created_at
     ProductQr{
       product_qr_code
       ProductBatch{
         product_full_name
       }
     }
   }
 }
}
''';

//===== DownlineTab
const String queryDownlineSales = r'''
query{
  downlineStats {
    User{
      UserMembership {
        membership_code
        membership_id
      }
      Orders{
        deduction
        OrderItems{
          total_price
        }
      }
      UserReferralTree{
        User{
          UserMembership {
            membership_code
            membership_id
          }
          Orders{
            deduction
            OrderItems{
              total_price
            }
          }
        }
        
      }
    }
  }
}
''';

//===== MyStatsTab
const String queryMyStats = r'''
query{
 User{
   UserMembership{
     UserMembershipCode{
       sales_target_quarterly
       sales_target_yearly
     }
   }
   Orders{
     created_at
     deduction
     OrderItems{
       total_price
     }
   }
 }
}
''';

//===== SettingsTab
// MyInfo
const String queryMyInfo = r'''
query{
 User{
  name
  address
  postcode
  city
  state
  country
  phone_number
 }
}
''';

String mutateMyInfo = r'''
  mutation updateUserProfile($userName: String!, $address: String!, $postcode: String!, 
  $city: String!, $state: String!, $country: String!, $phone: String!){
 updateUserProfile(input: {
   user:{
     username: $userName,
     address: $address,
     postcode: $postcode,
     city: $city,
     state:$state,
     country:$country
     phone_num:$phone
   }
 })
}
''';

// CompInfo
const String queryCompInfo = r'''
query{
 User{
 CompanyInfo{
  company_registration_number
  company_name
  company_address
  company_postcode
  company_city
  company_state
  company_country
  company_phone
  }
 }
}
''';

String mutateCompInfo = r'''
  mutation updateUserProfile($regNo: String!, $name: String!, $address: String!, $postcode: String!, 
  $city: String!, $state: String!, $country: String!, $phone: String!){
 updateUserProfile(input: {
   company:{
     reg_no: $regNo,
     name: $name,
     address: $address,
     postcode: $postcode,
     city: $city,
     state:$state,
     country:$country
     phone_num:$phone
   }
 })
}
''';

// BankInfo
const String queryBankInfo = r'''
query{
 User{
 BankAccount{
  bank_name
  bank_account_number
  }
 }
}
''';

String mutateBankInfo = r'''
  mutation updateUserProfile($bankName: String!, $bankAccNo: String!){
 updateUserProfile(input: {
   bank:{
     name: $bankName,
     account_no: $bankAccNo
   }
 })
}
''';