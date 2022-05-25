# Start your day, automatically!
# This script helps you get some extra minutes of peace and quit in, while working for you.
#
# $keepass_db_name -> The KeePass DB to open 
#

####################### Check if these globals are correct and change them if not #######################

# Name of KeePass DB
$keepass_db_name = "SomeKeePassDatabaseName.kdbx"

##########################################################################################################




# ------------------------------------------- leave this code alone ------------------------------------------
# global failcounter
$wait_counter = 0
# needed for sending keystrokes
$wshell = New-Object -ComObject wscript.shell;

# used to check if this is first start. you may not want to run some things on restart.
function is_first_start()
{
    $LogonEvents = Get-WinEvent -FilterHashTable @{ LogName = "System"; StartTime = (Get-Date -Hour 0 -Minute 0); ID = 7001 }
    if($LogonEvents.length -eq 1)
    {
        return $true
    } else
    {
        return $false
    }
}

# you may have to edit if your system isnt in german.
function wait_till_keepass_open() {
    if ($wshell.AppActivate($keepass_db_name + ' - KeePass')) {
        while(-Not $wshell.AppActivate($keepass_db_name + ' - KeePass')) {
            Sleep 1
        }
    } else {
        if (-Not $wshell.AppActivate('Datenbank öffnen - ' + $keepass_db_name)) {
            while(-Not $wshell.AppActivate('Datenbank öffnen - ' + $keepass_db_name)) {
                Sleep 1
            }
        }
        while($wshell.AppActivate('Datenbank öffnen - ' + $keepass_db_name)) {
            Sleep 1
        }
    }
}

function start_keepass() {
    $keepass_running = Get-Process keepass -ErrorAction SilentlyContinue
    if (-Not $keepass_running) {
        Start-Process "X:\Path\to\KeePass.exe"
        Sleep 5
        while(-Not $wshell.AppActivate($keepass_db_name + ' - KeePass')) {
            Sleep 1
        }
    }
}

# EXAMPLE -> Run another PowerShell script from within with powershell logon window (script in same path as this)
function connect_fileshares() {
    wait_till_keepass_open
    start powershell "$PSScriptRoot\do_some_thing.ps1"
    
    while (-Not $wshell.AppActivate('Anforderung für Windows PowerShell-Anmeldeinformationen.')) {
        $wait_counter = $wait_counter + 2
        if ($wait_counter -ge 12) {
            $wait_counter = 0
            return
        }
        Sleep 2
    }
    $wshell.SendKeys('(^%(i))') # -> KeePass auto-type login sequence
    Sleep 5
}

# EXAMPLE -> Start some Program with login 
function start_PROGRAMM() {
    wait_till_keepass_open

    $PROGRAM_NAME_running = Get-Process PROGRAM_NAME -ErrorAction SilentlyContinue
    if (-Not $PROGRAM_NAME_running) {
        Start-Process "X:\PATH\to\PROGRAM_NAME.exe"
    
        while(-Not $wshell.AppActivate('PROGRAM TITLE')) {
            $wait_counter = $wait_counter + 2
            if ($wait_counter -ge 12) {
                $wait_counter = 0
                return
            }
            Sleep 2
        }
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('(^%(i))')  # -> KeePass auto-type login sequence
        Sleep 5
    }
}


# EXAMPLE -> open websites with login with Edge
# --- Sites w/ Login
function login_website_1() {
    $wshell.AppActivate('Edge')
    start microsoft-edge:https://blah.blah.de
    Sleep 5
    $wshell.SendKeys('(^%(i))')  # -> KeePass auto-type login sequence
    Sleep 9
}

# exmaple with single sign on option
function login_website_2(){
    $wshell.AppActivate('Edge')
    start microsoft-edge:https://other-example.de
    Sleep 5
    $wshell.SendKeys('{TAB}')
    $wshell.SendKeys('{TAB}')
    $wshell.SendKeys('{TAB}')
    $wshell.SendKeys('{TAB}')
    $wshell.SendKeys('{ENTER}')
    Sleep 3
}

# --- Sites no Login
function open_slack() {
    $wshell.AppActivate('Edge')
    start microsoft-edge:https://your-slack-channel.com
    
    # only greet people on first start
    if (is_first_start) {
        Sleep 5
        #$wshell.SendKeys("+({UP})")
        #Sleep 3
        #$wshell.SendKeys("Ha-Ha, good joke! :joy:")
        #Sleep 5
        #$wshell.SendKeys('{ENTER}')
        #Sleep 3
        #$wshell.SendKeys('(^+(l))') # set focus to main chat 
        Sleep 2
        
        $emoji    = $emoji_array | Get-Random
        $greeting = $greeting_array | Get-Random
        $anrede   = $anrede_array | Get-Random
        $full_message = $greeting+", "+$anrede+"! "+$emoji

        $wshell.SendKeys($full_message)
        Sleep 8
        $wshell.SendKeys('{ENTER}')
        Sleep 1
    } 
    Sleep 5
}

function open_internal_page() {
    $wshell.AppActivate('Edge')
    start microsoft-edge:http://blah.internal.domain
    Sleep 1
}

function open_google() {
    $wshell.AppActivate('Edge')
    start microsoft-edge:https://www.google.de/
    Sleep 1
}

# EXAMPLE -> go to website and do something
function open_time_management() {
    $wshell.AppActivate('Edge')
    start microsoft-edge:https://some-other-link.com
    $wshell.AppActivate('Edge')
    if (is_first_start) {
        Sleep 8
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        Sleep 2

        $wshell.SendKeys('{ENTER}')

        Sleep 2
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        $wshell.SendKeys('{TAB}')
        Sleep 2

        $wshell.SendKeys('{DOWN}')
        Sleep 2
        $wshell.SendKeys('{ENTER}')
        Sleep 1
    }
    Sleep 5
}
# ------------------------------------------- leave this code alone ende ------------------------------------------






# ------------------- if you dont want to start/login some apps here then just comment out -------------------------
function main() {
    
    # KeePass MUST be started first
    start_keepass

    # Running another ps1 script to connect some fileshares, that need authentication (or any PowerShell script)
    connect_fileshares
    
    # Start a lokal program, wait till loaded, login
    start_PROGRAMM
    Sleep 5
    
    # Open Edge, go to website, login 
    login_website_1
    Sleep 5
    
    # Opens website in new tab, login
    login_website_2
    Sleep 5
    
    # open slack in new tab and say hi to the team
    open_slack
    Sleep 5
    
    # open some internal page
    open_internal_page
    Sleep 5
    
    # open google, why not?
    open_google
    
    # open some webapp and navigate/push some buttons
    # ich chose time management as an example since a lot of ppl work remote
    open_time_management

}
main






















$emoji_array = @(
    ":zzz:",
    ":dash:",
    ":sweat_drops:",
    ":notes:",
    ":musical_note:",
    ":fire:",
    ":hankey:",
    ":poop:",
    ":shit:",
    ":thumbsup:",
    ":thumbsdown:",
    ":ok_hand:",
    ":punch:",
    ":facepunch:",
    ":fist:",
    ":v:",
    ":wave:",
    ":hand:",
    ":raised_hand:",
    ":open_hands:",
    ":point_up:",
    ":point_down:",
    ":point_left:",
    ":point_right:",
    ":raised_hands:",
    ":pray:",
    ":point_up_2:",
    ":clap:",
    ":muscle:",
    ":metal:",
    ":fu:",
    ":runner:",
    ":running:",
    ":couple:",
    ":family:",
    ":two_men_holding_hands:",
    ":two_women_holding_hands:",
    ":dancer:",
    ":dancers:",
    ":ok_woman:",
    ":no_good:",
    ":information_desk_person:",
    ":raising_hand:",
    ":bride_with_veil:",
    ":person_with_pouting_face:",
    ":person_frowning:",
    ":bow:",
    ":couplekiss:",
    ":couple_with_heart:",
    ":massage:",
    ":haircut:",
    ":nail_care:",
    ":boy:",
    ":girl:",
    ":woman:",
    ":man:",
    ":baby:",
    ":older_woman:",
    ":older_man:",
    ":person_with_blond_hair:",
    ":man_with_gua_pi_mao:",
    ":man_with_turban:",
    ":construction_worker:",
    ":cop:",
    ":angel:",
    ":princess:",
    ":smiley_cat:",
    ":smile_cat:",
    ":heart_eyes_cat:",
    ":kissing_cat:",
    ":smirk_cat:",
    ":scream_cat:",
    ":crying_cat_face:",
    ":joy_cat:",
    ":pouting_cat:",
    ":japanese_ogre:",
    ":japanese_goblin:",
    ":see_no_evil:",
    ":hear_no_evil:",
    ":speak_no_evil:",
    ":guardsman:",
    ":skull:",
    ":feet:",
    ":lips:",
    ":kiss:",
    ":droplet:",
    ":ear:",
    ":eyes:",
    ":nose:",
    ":tongue:",
    ":love_letter:",
    ":bust_in_silhouette:",
    ":busts_in_silhouette:",
    ":speech_balloon:",
    ":thought_balloon:",
    ":feelsgood:",
    ":finnadie:",
    ":goberserk:",
    ":godmode:",
    ":hurtrealbad:",
    ":rage1:",
    ":rage2:",
    ":rage3:",
    ":rage4:",
    ":suspect:",
    ":trollface:",
    ":Nature:",
    ":sunny:",
    ":umbrella:",
    ":cloud:",
    ":snowflake:",
    ":snowman:",
    ":zap:",
    ":cyclone:",
    ":foggy:",
    ":ocean:",
    ":cat:",
    ":dog:",
    ":mouse:",
    ":hamster:",
    ":rabbit:",
    ":wolf:",
    ":frog:",
    ":tiger:",
    ":koala:",
    ":bear:",
    ":pig:",
    ":pig_nose:",
    ":cow:",
    ":boar:",
    ":monkey_face:",
    ":monkey:",
    ":horse:",
    ":racehorse:",
    ":camel:",
    ":sheep:",
    ":elephant:",
    ":panda_face:",
    ":snake:",
    ":bird:",
    ":baby_chick:",
    ":hatched_chick:",
    ":hatching_chick:",
    ":chicken:",
    ":penguin:",
    ":turtle:",
    ":bug:",
    ":honeybee:",
    ":ant:",
    ":beetle:",
    ":snail:",
    ":octopus:",
    ":tropical_fish:",
    ":fish:",
    ":whale:",
    ":whale2:",
    ":dolphin:",
    ":cow2:",
    ":ram:",
    ":rat:",
    ":water_buffalo:",
    ":tiger2:",
    ":rabbit2:",
    ":dragon:",
    ":goat:",
    ":rooster:",
    ":dog2:",
    ":pig2:",
    ":mouse2:",
    ":ox:",
    ":dragon_face:",
    ":blowfish:",
    ":crocodile:",
    ":dromedary_camel:",
    ":leopard:",
    ":cat2:",
    ":poodle:",
    ":paw_prints:",
    ":bouquet:",
    ":cherry_blossom:",
    ":tulip:",
    ":four_leaf_clover:",
    ":rose:",
    ":sunflower:",
    ":hibiscus:",
    ":maple_leaf:",
    ":leaves:",
    ":fallen_leaf:",
    ":herb:",
    ":mushroom:",
    ":cactus:",
    ":palm_tree:",
    ":evergreen_tree:",
    ":deciduous_tree:",
    ":chestnut:",
    ":seedling:",
    ":blossom:",
    ":ear_of_rice:",
    ":shell:",
    ":globe_with_meridians:",
    ":sun_with_face:",
    ":full_moon_with_face:",
    ":new_moon_with_face:",
    ":new_moon:",
    ":waxing_crescent_moon:",
    ":first_quarter_moon:",
    ":waxing_gibbous_moon:",
    ":full_moon:",
    ":waning_gibbous_moon:",
    ":last_quarter_moon:",
    ":waning_crescent_moon:",
    ":last_quarter_moon_with_face:",
    ":first_quarter_moon_with_face:",
    ":crescent_moon:",
    ":earth_africa:",
    ":earth_americas:",
    ":earth_asia:",
    ":volcano:",
    ":milky_way:",
    ":partly_sunny:",
    ":octocat:",
    ":squirrel:",
    ":Objects:",
    ":bamboo:",
    ":gift_heart:",
    ":dolls:",
    ":school_satchel:",
    ":mortar_board:",
    ":flags:",
    ":fireworks:",
    ":sparkler:",
    ":wind_chime:",
    ":rice_scene:",
    ":jack_o_lantern:",
    ":ghost:",
    ":santa:",
    ":christmas_tree:",
    ":gift:",
    ":bell:",
    ":no_bell:",
    ":tanabata_tree:",
    ":tada:",
    ":confetti_ball:",
    ":balloon:",
    ":crystal_ball:",
    ":cd:",
    ":dvd:",
    ":floppy_disk:",
    ":camera:",
    ":video_camera:",
    ":movie_camera:",
    ":computer:",
    ":tv:",
    ":iphone:",
    ":phone:",
    ":telephone:",
    ":telephone_receiver:",
    ":pager:",
    ":fax:",
    ":minidisc:",
    ":vhs:",
    ":sound:",
    ":speaker:",
    ":mute:",
    ":loudspeaker:",
    ":mega:",
    ":hourglass:",
    ":hourglass_flowing_sand:",
    ":alarm_clock:",
    ":watch:",
    ":radio:",
    ":satellite:",
    ":loop:",
    ":mag:",
    ":mag_right:",
    ":unlock:",
    ":lock:",
    ":lock_with_ink_pen:",
    ":closed_lock_with_key:",
    ":key:",
    ":bulb:",
    ":flashlight:",
    ":high_brightness:",
    ":low_brightness:",
    ":electric_plug:",
    ":battery:",
    ":calling:",
    ":email:",
    ":mailbox:",
    ":postbox:",
    ":bath:",
    ":bathtub:",
    ":shower:",
    ":toilet:",
    ":wrench:",
    ":nut_and_bolt:",
    ":hammer:",
    ":seat:",
    ":moneybag:",
    ":yen:",
    ":dollar:",
    ":pound:",
    ":euro:",
    ":credit_card:",
    ":money_with_wings:",
    ":e-mail:",
    ":inbox_tray:",
    ":outbox_tray:",
    ":envelope:",
    ":incoming_envelope:",
    ":postal_horn:",
    ":mailbox_closed:",
    ":mailbox_with_mail:",
    ":mailbox_with_no_mail:",
    ":package:",
    ":door:",
    ":smoking:",
    ":bomb:",
    ":gun:",
    ":hocho:",
    ":pill:",
    ":syringe:",
    ":page_facing_up:",
    ":page_with_curl:",
    ":bookmark_tabs:",
    ":bar_chart:",
    ":chart_with_upwards_trend:",
    ":chart_with_downwards_trend:",
    ":scroll:",
    ":clipboard:",
    ":calendar:",
    ":date:",
    ":card_index:",
    ":file_folder:",
    ":open_file_folder:",
    ":scissors:",
    ":pushpin:",
    ":paperclip:",
    ":black_nib:",
    ":pencil2:",
    ":straight_ruler:",
    ":triangular_ruler:",
    ":closed_book:",
    ":green_book:",
    ":blue_book:",
    ":orange_book:",
    ":notebook:",
    ":notebook_with_decorative_cover:",
    ":ledger:",
    ":books:",
    ":bookmark:",
    ":name_badge:",
    ":microscope:",
    ":telescope:",
    ":newspaper:",
    ":football:",
    ":basketball:",
    ":soccer:",
    ":baseball:",
    ":tennis:",
    ":8ball:",
    ":rugby_football:",
    ":bowling:",
    ":golf:",
    ":mountain_bicyclist:",
    ":bicyclist:",
    ":horse_racing:",
    ":snowboarder:",
    ":swimmer:",
    ":surfer:",
    ":ski:",
    ":spades:",
    ":hearts:",
    ":clubs:",
    ":diamonds:",
    ":gem:",
    ":ring:",
    ":trophy:",
    ":musical_score:",
    ":musical_keyboard:",
    ":violin:",
    ":space_invader:",
    ":video_game:",
    ":black_joker:",
    ":flower_playing_cards:",
    ":game_die:",
    ":dart:",
    ":mahjong:",
    ":clapper:",
    ":memo:",
    ":pencil:",
    ":book:",
    ":art:",
    ":microphone:",
    ":headphones:",
    ":trumpet:",
    ":saxophone:",
    ":guitar:",
    ":shoe:",
    ":sandal:",
    ":high_heel:",
    ":lipstick:",
    ":boot:",
    ":shirt:",
    ":tshirt:",
    ":necktie:",
    ":womans_clothes:",
    ":dress:",
    ":running_shirt_with_sash:",
    ":jeans:",
    ":kimono:",
    ":bikini:",
    ":ribbon:",
    ":tophat:",
    ":crown:",
    ":womans_hat:",
    ":mans_shoe:",
    ":closed_umbrella:",
    ":briefcase:",
    ":handbag:",
    ":pouch:",
    ":purse:",
    ":eyeglasses:",
    ":fishing_pole_and_fish:",
    ":coffee:",
    ":tea:",
    ":sake:",
    ":baby_bottle:",
    ":beer:",
    ":beers:",
    ":cocktail:",
    ":tropical_drink:",
    ":wine_glass:",
    ":fork_and_knife:",
    ":pizza:",
    ":hamburger:",
    ":fries:",
    ":poultry_leg:",
    ":meat_on_bone:",
    ":spaghetti:",
    ":curry:",
    ":fried_shrimp:",
    ":bento:",
    ":sushi:",
    ":fish_cake:",
    ":rice_ball:",
    ":rice_cracker:",
    ":rice:",
    ":ramen:",
    ":stew:",
    ":oden:",
    ":dango:",
    ":egg:",
    ":bread:",
    ":doughnut:",
    ":custard:",
    ":icecream:",
    ":ice_cream:",
    ":shaved_ice:",
    ":birthday:",
    ":cake:",
    ":cookie:",
    ":chocolate_bar:",
    ":candy:",
    ":lollipop:",
    ":honey_pot:",
    ":apple:",
    ":green_apple:",
    ":tangerine:",
    ":lemon:",
    ":cherries:",
    ":grapes:",
    ":watermelon:",
    ":strawberry:",
    ":peach:",
    ":melon:",
    ":banana:",
    ":pear:",
    ":pineapple:",
    ":sweet_potato:",
    ":eggplant:",
    ":tomato:",
    ":corn:",
    ":Places:",
    ":house:",
    ":house_with_garden:",
    ":school:",
    ":office:",
    ":post_office:",
    ":hospital:",
    ":bank:",
    ":convenience_store:",
    ":love_hotel:",
    ":hotel:"
)

$greeting_array = @(
    "Hi",
    "Morning",
    "G`day",
    "Howdy",
    "Hallo",
    "Guten Tag",
    "Guten morgen",
    "Moin",
    "Moinsen",
    "Tach",
    "Hallihallo",
    "Grüße",
    "Salü",
    "Hallöchen",
    "Servus"
)

$anrede_array = @(
    "Leute",
    "Gang",
    "Kollegen",
    "Alle",
    "Zusammen",
    "People",
    "Guys"
)





