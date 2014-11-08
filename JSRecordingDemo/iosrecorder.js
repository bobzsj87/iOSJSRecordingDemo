var iosrecorder = window.iosrecorder || {};
iosrecorder.record = function(){
    window.location = "iosrecorder:record";
}

iosrecorder.play = function(){
    window.location = "iosrecorder:play";
}


iosrecorder.stop = function(){
    window.location = "iosrecorder:stop";
}

iosrecorder.clear = function(){
    window.location = "iosrecorder:clear";
}

iosrecorder.upload = function(){
    window.location = "iosrecorder:upload";
}


function updateMeter(seconds, meter){
    document.getElementById('display').innerHTML = seconds + ", " +meter;
}