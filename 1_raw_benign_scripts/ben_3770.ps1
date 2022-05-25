# This file can be sourced and also executed directly

# Definitions and declarations go here

function main () {
    # All action happens here
    return 0
}

# Only run if not sourced
if($MyInvocation.InvocationName -eq '.') {
    main $args
}
