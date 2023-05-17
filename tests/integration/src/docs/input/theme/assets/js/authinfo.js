async function getUserInfo() {
    const response = await fetch('/.auth/me');
    const payload = await response.json();
    const { clientPrincipal } = payload;
    return clientPrincipal;
}


window.onload = async function() {
    const div = document.getElementById('authInfo');
    if (div) {
        try {
            const userInfo = await getUserInfo();
            if (userInfo && userInfo.userDetails) {
                div.textContent = userInfo.userDetails;
            }
            else {
                div.textContent = 'Anonymous';
            }
        }
        catch(e) {
            div.textContent = 'Anonymous!';
        }
    }
};