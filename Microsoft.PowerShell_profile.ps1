# To be placed in 
# C:\Users\ler015\Documents\WindowsPowerShell

function Commit-Git ($GitMessage){
    # Get date
    #$GIT_COMMITTER_DATE=$(python -c "import newdate; print(newdate.latedate())" 2>&1) 
    $date = $(python -c "import newdate; print(newdate.latedate())" 2>&1) 
    Set-Item -Path Env:GIT_COMMITTER_DATE -Value $date
    Write-Output "Commit date set to    : $Env:GIT_COMMITTER_DATE"
    Write-Output "Commit message set to : $GitMessage"
    git commit -m "$GitMessage" --date="$date"
}

function Show-Gitlog($Nlog)
{
    Write-Output "`n-------- Last $Nlog logs --------`n"
    git log -$Nlog --pretty="%h %s`n"
}
