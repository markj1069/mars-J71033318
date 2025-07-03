# process - Canonicalize the description and catagory.

function process () {

declare    -r    txn_in="$1"          # Save input transaction file.
declare    -r    txn_out="$2"         # Save output transaction file.


awk_program="$OLS_TMP_DIR/program.awk"

cat <<'/*' >"$awk_program"
BEGIN {

# Setup for a CSV.
    FS=","
   OFS=","

}

NR==1 { $1 = "Date"; $2 = "Description"; $3 = "Category"; $4 = "Check No."; $5 = "Amount"; $6 = "Memo" }  # Issue #32

$4 ~ /-/ { $4 = "" }                  # Issue #39

#---------------------------------------------------------------------------------------------------
#
# Google
#
#---------------------------------------------------------------------------------------------------
$2 ~ /GOOGLE \*Arlo Secure/ { $2 = "Google *Arlo"; $3 = "Personal Security" }
$2 ~ /GOOGLE \*FI/ { $2 = "Google *Fi"; $3 = "Utilities:Phone" }
$2 ~ /GOOGLE \*Google Fi/ { $2 = "Google *Fi"; $3 = "Utilities:Phone" }  # Issue #36
$2 ~ /GOOGLE \*YouTubePremium/ { $2 = "Google *YouTube Premium"; $3 = "Entertainment:Subscription" }
$2 ~ /GOOGLE \*YOUTUBE TV/ { $2 = "Google *YouTube TV"; $3 = "Entertainment:Subscription" }
$2 ~ /GOOGLE \*Pandora/ { $2 = "Google *Pandora"; $3 = "Entertainment:Subscription" }
$2 ~ /GOOGLE \*MyFitnessPal/ { $2 = "Google *MyFitnessPal"; $3 = "Health & Fitness:Supplies & Equipment" } # Issue 28
$2 ~ /GOOGLE \*Viet Tran/ { $2 = "Google *Pay"; $3 = "Misc" }

$2 ~ /USAA INSURANCE PAYMENT/ { $2 = "USAA Insurance"; $3 = "Home:Home Insurance" }  # Issue #20

$2 ~ /PURCHASE INTEREST CHARGE/ { $2 = "Finance Charge"; $3 = "Fees & Charges:Finance Charge" }  # Issue #31

#---------------------------------------------------------------------------------------------------
#
# Amazon
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Prime Video/ { $2 = "Amazon Prime Video"; $3 = "Entertainment:Movies & DVDs" }  # Issue #35, #3
$2 ~ /Amazon Prime\*/ { $2 = "Amazon Prime"; $3 = "Shopping" }  # Issue $35
$2 ~ /Amazon.com/ { $2 = "Amazon"; $3 = "Shopping" }
$2 ~ /AMAZON MKTPL/ { $2 = "Amazon"; $3 = "Shopping" }
$2 ~ /Amazon.com/ { $2 = "Amazon"; $3 = "Shopping" }
$2 ~ /Audible/ { $2 = "Amazon Audible"; $3 = "Entertainment:Subscription" }  # Issue #1
$2 ~ /AMZN/ { $2 = "Amazon"; $3 = "Shopping" }

#---------------------------------------------------------------------------------------------------
#
# Microsoft
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Microsoft\*Skype/ { $2 = "Microsoft *Skype"; $3 = "Utilities:Phone" } # Issue #42


#---------------------------------------------------------------------------------------------------
#
# Verizon
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Verizon/ { $2 = "Verizon"; $3 = "Utilities:Internet" }
$2 ~ /VERIZON/ { $2 = "Verizon"; $3 = "Utilities:Internet" }


#---------------------------------------------------------------------------------------------------
#
# Microsoft
#
#---------------------------------------------------------------------------------------------------
$2 ~ /MARATHON PETRO/ { $2 = "Marathon Petroleum"; $3 = "Auto:Gas" } # Issue #58
$2 ~ /PILOT/ { $2 = "Pilot Travel Center"; $3 = "Auto:Gas" }


#---------------------------------------------------------------------------------------------------
#
# Education
#
#---------------------------------------------------------------------------------------------------
$2 ~ /ZOTERO/ { $2 = "Sirius/XM"; $3 = "Education:Expenses" }  # Issue #42


#---------------------------------------------------------------------------------------------------
#
# Entertainment:Music
#
#---------------------------------------------------------------------------------------------------
$2 ~ /SXM\*SIRIUSXM.COM/ { $2 = "Sirius/XM"; $3 = "Entertainment:Music" }  # Issue #42

#---------------------------------------------------------------------------------------------------
#
# Entertainment:Video
#
#---------------------------------------------------------------------------------------------------
$2 ~ /FP \*RUMBLE USA/ { $2 = "Rumble"; $3 = "Entertainment:Video" }  # Issue #36
$2 ~ /CURIOSITYSTREAM/ { $2 = "Curiosity Stream"; $3 = "Entertainment:Video" }


#---------------------------------------------------------------------------------------------------
#
# Fees & Charges
#
#---------------------------------------------------------------------------------------------------
$2 ~ /ATM - TRANSACTION FEE/ { $2 = "ATM Transaction Fee"; $3 = "Fees & Charges:ATM Fee" }  # Issue #57

#---------------------------------------------------------------------------------------------------
#
# Food & Dining: Groceries
#
#---------------------------------------------------------------------------------------------------
$2 ~ /GUNDRY MD  LLC/ { $2 = "Dr. Gundry LLC"; $3 = "Food & Dining:Groceries" }
$2 ~ /BURRY CHOCOLATES/ { $2 = "Burry Chocolates"; $3 = "Food & Dining:Groceries" }  # Issue $37
$2 ~ /TST\*TRUE BLUE BUTCHER/ { $2 = "True Blue Butcher & Baker"; $3 = "Food & Dining:Groceries" }  # Issue #5
$2 ~ /TST\* TRUE BLUE BUTCHER/ { $2 = "True Blue Butcher & Baker"; $3 = "Food & Dining:Groceries" }  # Issue #42
$2 ~ /BIGGERS MARKET/ { $2 = "Biggers Market"; $3 = "Food & Dining:Groceries" }  # Issue #37
$2 ~ /WHOLEFDS/ { $2 = "Whole Foods"; $3 = "Food & Dining:Groceries" }  # Issue #56

#---------------------------------------------------------------------------------------------------
#
# Food & Dining: Fast Food
#
#---------------------------------------------------------------------------------------------------
$2 ~ /WENDYS/ { $2 = "Wendy's"; $3 = "Food & Dining:Fast Food" }  # Issue #36
$2 ~ /WENDY'S/ { $2 = "Wendy's"; $3 = "Food & Dining:Fast Food" }
$2 ~ /CHICK-FIL-A/ { $2 = "Chick-fil-A"; $3 = "Food & Dining:Fast Food" }  # Issue #24
$2 ~ /COOK OUT/ { $2 = "Cook Out"; $3 = "Food & Dining:Fast Food" }
$2 ~ /FAZOLIS/ { $2 = "Fazolis"; $3 = "Food & Dining:Fast Food" }  # Issue #58
$2 ~ /MCDONALD'S/ { $2 = "McDonald's"; $3 = "Food & Dining:Fast Food" }  # Issue #42
$2 ~ /SONIC DRIVE IN/ { $2 = "Sonic Drive-In"; $3 = "Food & Dining:Fast Food" }  # Issue #36

$2 ~ /CHIPOTLE/ { $2 = "Chipolte"; $3 = "Food & Dining:Restaurants" }  # Issue #30

$2 ~ /THE UPS STORE/ { $2 = "The UPS Store"; $3 = "Shipping" }

$2 ~ /YSI\*Stephens Pointe/ { $2 = "Stephens Pointe Apartments"; $3 = "Home:Rent" }  # Issue #17

$2 ~ /GO STORE IT/ { $2 = "Go Store It"; $3 = "Home:Rent" }  # Issue #14

$2 ~ /CHICKEN SALAD CHICK/ { $2 = "Chicken Salad Chick"; $3 = "Food & Dining:Restaurants" }  # Issue #15

$2 ~ /CRACKER BARREL/ { $2 = "Cracker Barrel"; $3 = "Food & Dining:Restaurants" }

#---------------------------------------------------------------------------------------------------
#
# Food & Dining: Restaurants
#
#---------------------------------------------------------------------------------------------------
$2 ~ /PAR\*LIVE.EAT.SURF/ { $2 = "K38 Baja Gril"; $3 = "Food & Dining:Restaurants" }
$2 ~ /TST\*CAPE FEAR SEAFOOD/ { $2 = "Cape Fear Seafood"; $3 = "Food & Dining:Restaurants" }  # Issue #36
$2 ~ /DOCKSIDE MARINA/ { $2 = "Dockside Marina"; $3 = "Food & Dining:Restaurants" }
$2 ~ /GREAT CHINA/ { $2 = "Great Wall"; $3 = "Food & Dining:Restaurants" }  # Issue #42
$2 ~ /JOHNNYLUKES KITCHENBAR/ { $2 = "Johnny's Lukes Kitchen Bar"; $3 = "Food & Dining:Restaurants" }
$2 ~ /TST\* KORNERSTONE BISTR/ { $2 = "Kornerstone Bistro"; $3 = "Food & Dining:Restaurants" }  # Issue #44
$2 ~ /K&W CAFETERIA/ { $2 = "K&W Cafeteria"; $3 = "Food & Dining:Restaurants" }  # Issue #42
$2 ~ /LONGHORN STEAK/ { $2 = "Longhorn Steakhouse"; $3 = "Food & Dining:Groceries" }  # Issue #58
$2 ~ /PANERA BREAD/ { $2 = "Panera Bread"; $3 = "Food & Dining:Restaurants" }  # Issue #44
$2 ~ /PAUL'S PLACE/ { $2 = "Paul's Place Famous Hot Dogs"; $3 = "Food & Dining:Restaurants" }  # Issue #36
$2 ~ /PAUL S PLACE/ { $2 = "Paul's Place Famous Hot Dogs"; $3 = "Food & Dining:Restaurants" }

$2 ~ /RUBY TUESDAY/ { $2 = "Ruby Tuesday"; $3 = "Food & Dining:Restaurants" }  # Issue #15
$2 ~ /TST\* SAWMILL GRILL/ { $2 = "Sawmill Grill"; $3 = "Food & Dining:Restaurants" }
$2 ~ /SCNB/ { $2 = "Smithfield's Checken 'n Bar-B-Q"; $3 = "Food & Dining:Restaurants" }
$2 ~ /TST\* TIDEWATER OYSTER/ { $2 = "Tidewater Oyster Bar"; $3 = "Food & Dining:Restaurants" }  # Issue #42

$2 ~ /TST\* HWY 55/ { $2 = "HWY 55"; $3 = "Food & Dining:Restaurants" }
$2 ~ /ZAXBY'S/ { $2 = "Zaxby's"; $3 = "Food & Dining:Restaurants" }  # Issue #25


$2 ~ /LA MER NAILS/ { $2 = "La Mer Nails & Spa"; $3 = "Personal Services:Nails" }


#---------------------------------------------------------------------------------------------------
#
# Food & Dining: Coffee Shops
#
#---------------------------------------------------------------------------------------------------
$2 ~ /PORT CITY JAVA/ { $2 = "Port City Java"; $3 = "Food & Dining:Coffee Shops" }

$2 ~ /BROWN DOG COFFEE COMPANY/ { $2 = "Brown Dog Coffee"; $3 = "Food & Dining:Coffee Shops" }

$2 ~ /SQ \*CASABLANCA COFFEE/ { $2 = "Casa Blanca Coffee Roasters"; $3 = "Food & Dining:Coffee Shops" }
$2 ~ /PAYPAL \*HOVER/ { $2 = "PayPal *Hover"; $3 = "Office:Service" }
$2 ~ /Withdrawal PAYPAL/ { $2 = "LinkedIn (Lynda)"; $3 = "Education:Tuition" }
$2 ~ /PAYPAL \*LEMONSQUEEZ/ { $2 = "PayPal *Lemon Squeez"; $3 = "Food & Dining:Coffee Shops" }
$2 ~ /SQ \*MATTER MORE COFFEE/ { $2 = "Matter More Coffee"; $3 = "Food & Dining:Coffee Shops" }  # Issue #29

$2 ~ /STARBUCKS/ { $2 = "Starbucks"; $3 = "Food & Dining:Coffee Shops" }


$2 ~ /HARRIS TEETER/ { $2 = "Harris Teeter"; $3 = "Food & Dining:Groceries" }  # Issue #8

$2 ~ /PUBLIX/ { $2 = "Publix"; $3 = "Food & Dining:Groceries" }  # Issue #7

$2 ~ /FOOD LION/ { $2 = "Food Lion"; $3 = "Food & Dining:Groceries" }  # Issue #19

$2 ~ /COLDSTONE/ { $2 = "Cold Stone Creamery"; $3 = "Food & Dining:Fast Food" }  # Issue #27

$2 ~ /STEVENS HARDWARE/ { $2 = "Stephens Hardware"; $3 = "Home:Home Supplies" }

$2 ~ /PIZZA HUT/ { $2 = "Pizza Hut"; $3 = "Food & Dining:Restaurants" }

$2 ~ /DOMINO'S/ { $2 = "Domino's"; $3 = "Food & Dining:Restaurants" }

$2 ~ /TST\* BRIDGEWATER WINES/ { $2 = "Bridgewater Wines + Dines"; $3 = "Food & Dining:Restaurants" }

$2 ~ /SPEEDWAY/ { $2 = "Speedway"; $3 = "Auto:Gas" }  # Issue #10

$2 ~ /OPTAVIA/ { $2 = "Optavia"; $3 = "Food & Dining:Groceries" }  # Issue #16

$2 ~ /WAL[-]*MART/ { $2 = "Walmart"; $3 = "Food & Dining:Groceries" }
$2 ~ /WM SUPERCENTER/ { $2 = "Walmart"; $3 = "Food & Dining:Groceries" }

$2 ~ /LOWES #/ { $2 = "Lowes Home Improvement"; $3 = "Home:Home Supplies" }  # Issue #11

$2 ~ /EAGLE ISLAND FRUIT/ { $2 = "Eagle Island Fruit & Seafood"; $3 = "Food & Dining:Groceries" }

$2 ~ /COSTCO WHSE/ { $2 = "Costco Wholesale"; $3 = "Food & Dining:Groceries" }

$2 ~ /SP GOOD RANCHERS/ { $2 = "Good Ranchers"; $3 = "Food & Dining:Groceries" }

$2 ~ /BURGER KING/ { $2 = "Burger King"; $3 = "Food & Dining:Fast Food" }

$2 ~ /DAIRY QUEEN/ { $2 = "Dairy Queen"; $3 = "Food & Dining:Fast Food" }

$2 ~ /TACO BELL/ { $2 = "Taco Bell"; $3 = "Food & Dining:Fast Food" }

$2 ~ /CELTIC CREAMERY OF PORTER/ { $2 = "Celtic Creamery of Porters Neck"; $3 = "Food & Dining:Fast Food" }

$2 ~ /THE DONUT INN/ { $2 = "The Donut Inn"; $3 = "Food & Dining:Fast Food" }

$2 ~ /HARDEES/ { $2 = "Hardees"; $3 = "Food & Dining:Fast Food" }  # Issue #4

$2 ~ /TST\*FAT DADDYS / { $2 = "Fat Daddy's Pizza"; $3 = "Food & Dining:Restaurants" }

$2 ~ /AU BON PAIN/ { $2 = "Au Bon Pain"; $3 = "Food & Dining:Restaurants" }

$2 ~ /MISSION BBQ/ { $2 = "Mission BBQ"; $3 = "Food & Dining:Restaurants" }

$2 ~ /CHINA ONE/ { $2 = "China One"; $3 = "Food & Dining:Restaurants" }

$2 ~ /A TASTE OF SUNRISE LLC/ { $2 = "A Taste of Sunrise"; $3 = "Food & Dining:Restaurants" }

$2 ~ /TST\*BURGAW BREWING/ { $2 = "Burgaw Brewing"; $3 = "Food & Dining:Restaurants" }
$2 ~ /TST\* BURGAW BREWING/ { $2 = "Burgaw Brewing"; $3 = "Food & Dining:Restaurants" }

$2 ~ /SP GOAXIL/ { $2 = "Axil"; $3 = "Health & Fitness:Supplies & Equipment" }

$2 ~ /SQ \*ISLANDS FRESH MEX/ { $2 = "Islands Fresh Mex Grill"; $3 = "Food & Dining:Restaurants" }

$2 ~ /TST\* CORNELIA'S/ { $2 = "Cornelia's"; $3 = "Food & Dining:Restaurants" }

$2 ~ /BORI CAFE BAR/ { $2 = "Bori Café Bar"; $3 = "Food & Dining:Restaurants" }

$2 ~ /TWO GUYS GRILL/ { $2 = "Two Guys Grille"; $3 = "Food & Dining:Restaurants" }

$5 ~ /838.00/ { $2 = "Schwab Brokerage IRA"; $3 = "Income:IRA" }
$5 ~ /787.00/ { $2 = "Schwab Brokerage IRA"; $3 = "Income:IRA" }



$2 ~ /Spectrum/ { $2 = "Spectrum Cable/Charter Communications"; $3 = "Utilities:Internet" }

$2 ~ /FAIRWAY FORD/ { $2 = "Fairway Ford"; $3 = "Auto:Parts & Services" }

$2 ~ /FSP\*FLEET FEET/ { $2 = "Fleet Feet"; $3 = "Shopping:Clothes" }



$2 ~ /DOLLAR GENERAL/ { $2 = "Dollar General"; $3 = "Home:Home Supplies" }  # Issue #9

$2 ~ /WWW.MOMSMEALS.COM/ { $2 = "Mom's Meals"; $3 = "Food & Dining:Groceries" }

#---------------------------------------------------------------------------------------------------
#
# Health & Fitness:Medical Professional
#
#---------------------------------------------------------------------------------------------------
$2 ~ /BODIES IN BALANCE/ { $2 = "Bodies in Balance"; $3 = "Health & Fitness:Medical Professional" }
$2 ~ /DERMATOLOGY ASSOCIATES/ { $2 = "Dermatology Associates"; $3 = "Health & Fitness:Medical Professional" }
$2 ~ /NEW HANOVER CS\/GUAR/ { $2 = "NHRMC"; $3 = "Health & Fitness:Medical Professional" }
$2 ~ /NHCI NEW HAN/ { $2 = "NHRMC"; $3 = "Health & Fitness:Medical Professional" }
$2 ~ /NEW HANOVER REGIONAL MED/ { $2 = "NHRMC"; $3 = "Health & Fitness:Medical Professional" }
$2 ~ /NOVANTHEAL/ { $2 = "NHRMC"; $3 = "Health & Fitness:Medical Professional" }  # Issue #41
$2 ~ /SENIOR CARE SYSTEM/ { $2 = "Health Partners"; $3 = "Health & Fitness:Medical Professional" }  # Issue #40
$2 ~ /SUMMIT PODIATRY/ { $2 = "Summit Podiatry"; $3 = "Health & Fitness:Medical Professional" }  # Issue #41

$2 ~ /CENTERWELL PHARMACY/ { $2 = "Centerwell Pharmacy"; $3 = "Health & Fitness:Pharmacy" }  # Issue #41
$2 ~ /LASTPASS.COM/ { $2 = "Lastpass"; $3 = "Office:Software Subscription" }
$2 ~ /NORTON/ { $2 = "Norton"; $3 = "Office:Software Subscription" }
$2 ~ /Citi Credit Card/ { $2 = "\"USAA Checking --> Costco Citi\""; $3 = "Costco Visa 4995" }
$2 ~ /Lowe's Credit/ { $2 = "\"USAA Checking --> Lowes's Credit\""; $3 = "Lowes Credit" }

$2 ~ /CONTACTS+/ { $2 = "Contacts+"; $3 = "Office:Software Subscription" }

$2 ~ /JOHNSON DRUG/ { $2 = "Johnson Drug & Home Medical"; $3 = "Health & Fitness:Supplies & Equipment" }

$2 ~ /HOME INSTEAD SENIOR CARE/ { $2 = "Home Instead"; $3 = "Health & Fitness:Caregivers" }

$2 ~ /WALGREENS/ { $2 = "Walgreens"; $3 = "Food & Dining:Groceries" }

$2 ~ /CAROLINASDENTIST/ { $2 = "CarolinaDentists"; $3 = "Health & Fitness:Dentist" }
$2 ~ /Genworth Life/ { $2 = "Genworth Life LTC"; $3 = "Health & Fitness:Health Insurance:Marian's LTC" }

$2 ~ /SALINES-MONDELLO.../ { $2 = "Salines-Mondello Law Firm"; $3 = "Office:Legal" }

$2 ~ /NEW HANOVER CO ABC/ { $2 = "ABC Store"; $3 = "Food & Dining:Groceries" }

$2 ~ /CATINO EYE CARE/ { $2 = "Catino Eye Care"; $3 = "Health & Fitness:Eye Care Expenses" }

$2 ~ /THE PLANT PLACE/ { $2 = "The Plant Place"; $3 = "Home:Home Supplies" }

$2 ~ /[0-9]+ GREAT CLIPS/ { $2 = "Great Clips"; $3 = "Personal Services:Hair" }

$2 ~ /INTEREST CHARGE/ { $2 = "Finance Charge"; $3 = "Fees & Charges:Finance Charge" }  # Issue #40
$2 ~ /Interest Paid/ { $2 = "Interest Income"; $3 = "Income:Interest Income" }
$2 ~ /Interest Earned/ { $2 = "Interest Income"; $3 = "Income:Interest Income" } 
$2 ~ /Taxes Withheld/ { $2 = "Taxes Withheld"; $3 = "Taxes:Federal Tax" } 


$2 ~ /Discover Credit Card/ { $2 = "\"USAA Checking --> Discover\""; $3 = "Discover 9231" }
$2 ~ /Bank of America MasterCard/ { $2 = "\"USAA Checking --> BoAMC\""; $3 = "BoA MC 0543" }
$2 ~ /Chase Credit/ { $2 = "\"USAA Checking --> Amazon\""; $3 = "Amazon-Chase 1009" }
$2 ~ /Duke Energy/ { $2 = "Duke Energy"; $3 = "Utilities:Power" }

$2 ~ /LATE FEE/ { $2 = "Late Fee"; $3 = "Fees & Charges:Late Fee" }
$2 ~ /LATE PAYMENT FEE/ { $2 = "Late Fee"; $3 = "Fees & Charges:Late Fee" }

$2 ~ /INTERNET PAYMENT/ { $2 = "Payment"; $3 = "Payment" }  # Issue #40
$2 ~ /Withdrawal BARCLAY/ { $2 = "MFCU --> Barclays"; $3 = "Barclays MC 1602" }
$2 ~ /Deposit XXSOC SEC/ { $2 = "Social Security"; $3 = "Income:Social Security" }
$2 ~ /Social Security/ { $2 = "Social Security"; $3 = "Income:Social Security" }
$2 ~ /Withdrawal CHASE CREDIT/ { $2 = "MFCU --> Amazon-Chase"; $3 = "Amazon-Chase 1009" }
$2 ~ /Withdrawal STATE FARM/ { $2 = "State Farm Life"; $3 = "Financial:Life Insurance" }
$2 ~ /State Farm/ { $2 = "State Farm Life"; $3 = "Financial:Life Insurance" }
$2 ~ /Withdrawal AMEX EPAYMENT/ { $2 = "MFCU --> AmEx"; $3 = "AmEx 3001 Delta" }
$2 ~ /Withdrawal HUMANA COMP/ { $2 = "Humana"; $3 = "Health & Fitness:Health Insurance" }
$2 ~ /Humana/ { $2 = "Humana"; $3 = "Health & Fitness:Health Insurance" }
$2 ~ /Cigna/ { $2 = "Cigna"; $3 = "Health & Fitness:Health Insurance" }
$2 ~ /Deposit PRU/ { $2 = "Prudential"; $3 = "Income:Pension" }
$2 ~ /Withdrawal BK OF AMER MC/ { $2 = "MFCU --> BoA MC"; $3 = "BoA MC 0543" }
$2 ~ /Deposit Home Banking Transfer/ { $2 = "Xfer"; $3 = "MFCU Savings" }
$2 ~ /Deposit Transfer From Share/ { $2 = "Xfer"; $3 = "MFCU Savings" }
$2 ~ /Withdrawal DISCOVER/ { $2 = "MFCU --> Discover"; $3 = "Discover 9231" }
$2 ~ /Deposit Dividend/ { $2 = "Interest Income"; $3 = "Income:Interest Income" }
$2 ~ /ELECTRONIC PAYMENT/ { $2 = "Electronic Payment" }  # Issue #57


#---------------------------------------------------------------------------------------------------
#
# Home
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Kristie Watkins/ { $2 = "Kristie Watkins"; $3 = "Home:Home Services" }
$2 ~ /Tammy Watts/ { $2 = "Tammy Watts:Carolina Spring Cleaning"; $3 = "Home:Home Services" }


#---------------------------------------------------------------------------------------------------
#
# Personal Security
#
#---------------------------------------------------------------------------------------------------
$2 ~ /GOVMNTAPPS/ { $2 = "Government Payment Processing"; $3 = "Personal Security" }
$2 ~ /US LAW SHIELD/ { $2 = "US Law Shield"; $3 = "Personal Security" }
$2 ~ /BACKWATER GUNS/ { $2 = "Backwater Guns and Outfitters"; $3 = "Personal Security" }


#---------------------------------------------------------------------------------------------------
#
# Personal Services
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Jennifer Malpass/ { $2 = "Jennifer Malpass Salon"; $3 = "Personal Services:Hair" }
$2 ~ /THE REAL DEA-656096/ { $2 = "ATM Cash"; $3 = "Personal Services:Hair"; $6 = "Jennifer Malpass" }  # Issue #57


#---------------------------------------------------------------------------------------------------
#
# Taxes
#
#---------------------------------------------------------------------------------------------------
$2 ~ /DOR TAX PAYMENTS/ { $2 = "NC Dept of Revenue"; $3 = "Taxes:State Tax" }  # Issue #37
$2 ~ /GOV\*NC DMV/ { $2 = "NC Dept of Moter Vehicles"; $3 = "Taxes:Vehicle Registration" }  # Issue #37
$2 ~ /INTUIT \*TURBOTAX/ { $2 = "Intuit *Turbotax"; $3 = "Taxes:Tax Prep" }  # Issue #37
$2 ~ /SERVICE FEE/ { $2 = "Service Fee"; $3 = "Taxes:Tax Prep" }  # Issue #37
$2 ~ /US TREAS TAX PYMT/ { $2 = "US Treasury"; $3 = "Taxes:Federal Tax" }  # Issue #37
$2 ~ /TREASURY SERV/ { $2 = "US Treasury"; $3 = "Taxes:Tax Prep" }  # Issue #37
$2 ~ /TREASURY PMNT/ { $2 = "US Treasury"; $3 = "Taxes:Federal Tax" }  # Issue #37


#---------------------------------------------------------------------------------------------------
#
# Travel
#
#---------------------------------------------------------------------------------------------------
$2 ~ /Hotel Res-Home2 Suites/ { $2 = "Hotel Reservation"; $3 = "Travel:Hotel"; $6 = "Home2 Suites" }
$2 ~ /HOME2 SUITES/ { $2 = "Home2 Suites"; $3 = "Travel:Hotel"; $6 = "Home2 Suites" }
$2 ~ /HOTELBOOKING\*SERVFEE/ { $2 = "Hotel Booking"; $3 = "Fees & Charges:Service Fees" }


{ print $0 }

/*



awk --file="$awk_program" "$txn_in" >"$txn_out"

}  # process
