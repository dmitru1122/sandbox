import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const showError = (error, isInternal) => {
    let errorMessage = '';

    if(!isInternal) {
        if (error) {
            if (Array.isArray(error.body)) {
                errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                errorMessage = error.body.message;
            }
        } else { 
            errorMessage = '';
        }
    } else {
        errorMessage = error;
    }

    if(errorMessage) {
        const eventToast = new ShowToastEvent({
            "title": "Error",
            "message": errorMessage,
            "variant": "error",
            "mode":"sticky"
        });
        dispatchEvent(eventToast);
    }
}


export { showError };