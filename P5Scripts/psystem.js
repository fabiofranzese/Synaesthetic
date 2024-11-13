let allP = [];

function initParticles(){

  
  for(let i=0;i<300;i++){
  
      
   let rf = int(random(0,5)); 
    
    let np = new aP(i,rf);
    np.pos.x = random(w);
    np.pos.y = random(h);
    allP.push( np);
  
  }
  
  

}

function updateParticles(){


     
  for(let i=0;i<allP.length;i++){
  
      allP[i].updateMe();
  
  }
  

}
