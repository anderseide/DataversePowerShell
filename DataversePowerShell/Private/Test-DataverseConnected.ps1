function Test-DataverseConnected {
    if ($DataverseSession.AuthSession) {
        return $true
    }
    else {
        return $false
    }
}