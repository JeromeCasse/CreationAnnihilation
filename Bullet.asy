settings.outformat = "pdf" ;

size(20cm,20cm) ;

srand(40) ; 

//taille fenetre
int haut = 10 ;
int larg = 10 ;
draw((0,0)--(0,haut)--(larg,haut)--(larg,0)--cycle,white) ;

//parameters ;
real lambda0 = 1 ;
real lambdaV = 0 ;
real lambdaH = 0 ;
real tauV = 1 ;
real tauH = 1 ;
real p0 = 1 ;
real pV = 0 ;
real pH = 0 ;
real pC = 1-p0-pV-pH ;

//parametre du bord
real nuV = 0 ;
real nuH = 0 ;


//comparaison des pairs par leurs ordonnées
bool cmp(pair p1, pair p2) {
  return p1.y < p2.y;
}

//comparaison des réels
bool pp(real x1, real x2) {
  return x1 < x2 ;
}

//variable expo de parametre lambda (moyenne = 1/lambda)
real random_exponential(real lambda) {
  return -1/lambda * log(1 - unitrand());
}

//loi uniforme sur {1,2,...,n}
int random_uniform_int(int n){
  int res = 0 ;
  real aux = n*unitrand() ;
  for(int i = 0 ; i< aux ; ++i){
    res = res + 1 ;
  } ;
  return res ;
}
      
//loi de poisson de parametre lambda
int random_poisson(real lambda){
  real sum = 0 ;
  int j = 0 ;
  for(int i ; sum < lambda ; ++i){
    sum = sum + random_exponential(1) ;
    j=i ;
  } ;
  return j ;
}

//np points ind uniformes triés sur [deb,fin]
real[] random_ppp(int np,real deb, real fin){
  real[] aux ;
  for(int i=0 ; i< np ; ++i){
    aux[i] = deb + (fin-deb)*unitrand() ;
  } ;
  real[] res = sort(aux,pp);
  return res ;
}

//np points uniformes triés par ordonnés dans le rectangle [0,l] x [0,h] 
pair[] random_ppp_2(int np, real l, real h){
  pair[] aux ;
  for(int i = 0 ; i<np ; ++i){
    aux[i] = (l*unitrand(),h*unitrand() ) ;
  } ;
  pair[] res = sort(aux,cmp);
  return res ;
}

int n0 = random_poisson(lambda0*haut*larg) ;
int nH = random_poisson(nuH*haut) ;
int nV = random_poisson(nuV*larg) ;

pen hori = blue ;
pen vert = red ;

//le ppp des arrivées sur le bas
real[] init = random_ppp(nV,0,larg) ;

//write(nV) ;
//write(init) ;

//le ppp des creas ex-nihilo
pair[] ppp = random_ppp_2(n0,haut,larg) ;
//j'y rajoute le PPP des arrivées sur la gauche
for(int i = n0 ; i < n0 + nH ; ++i){
  ppp[i] = (0,haut*unitrand()) ;
} ;
pair[] creas = sort(ppp,cmp) ;

//write(n0) ;
//write(nH) ;
//write(creas) ;

real[] config ; 
config[0] = 0 ; //l'ordonnée à laquelle on est 
for(int i=1 ; i <= nV ; ++i){
  config[i] = init[i-1] ;
} ;

//fonction pour trouver le premier point dans creas au dessus de l'ordonnée y, renvoit n0+nH si aucun point au-dessus
int next_crea(real yy){
  int res = 0 ;
  for(int i=0 ; i < n0+nH ; ++i){
    if(creas[i].y <= yy){ //structure étrange, mais sinon j'ai une erreur. Si on rentre creas[j].y, on souhaite j+1.
      res = res + 1 ;
    } ;
  } ;
  return res ;
} ;

//temps de la prochaine crea ou virage d'une particule verticale, si vide ou grand retourner haut+1
real next_jump(real[] config){
  int size = config.length -1 ;
  if((lambdaV+tauV)*size == 0){
    return haut ; 
  } else {
    return min(haut,config[0] + (random_exponential((lambdaV+tauV)*size))) ;
  } ;
} ;

//tracer les particules verticales d'une config jusqu'au temps time
void draw_vert(real[] config,real time){
  int size = config.length -1 ;
  if(size > 0){
    for(int i=1 ; i <= size ; ++i){
      draw((config[i],config[0])--(config[i],time),vert) ;
    } ;
  } ;
} ;

//compliquer : une config + un debx + une finx, on renvoit la liste des points verticaux qui survivent en dehors de debx et finx 
real[] survive(real[] config, real debx, real finx){
  real[] res ;
  int j = 0 ;
  for(int i=1 ; i <= config.length-1 ; ++i){
    if(config[i] < debx || config[i] > finx){
      res[j] = config[i] ;
      j = j + 1 ;
    } ;
    if(config[i] > debx & config[i] < finx){
      if((pC+pH)*unitrand()<pC){
	res[j] = config[i] ;
	j=j+1 ;
      } ;
    } ;
  } ;
  return res ;
}

//compliquer : une config + une deb, on renvoit une fin
real fin_saut(real[] config, real deb){
  real res = larg ;
  if(tauH > 0){
    res = min(larg,deb + random_exponential(tauH)) ;
  } ;
  return res ;
} ;

//renvoit le premier temps qui tue la particule horizontale, si personne ne la tue renvoit 0
int before_saut(real[] config, real deb, real finS){
  int res = 0 ;
  for(int i=config.length - 1 ; i > 0 ; --i){
    if((config[i] < finS) & config[i] > deb){
      if(unitrand() < p0+pV){
	res = i ;
      } ;
    } ;
  } ;
  return res ;
} ;

//concatener les copains et les trie
real[] concatener(real[] t1, real[] t2, real[] t3){
  real[] aux ;
  int l1 = t1.length;
  int l2 = t2.length ;
  int l3 = t3.length ;
  for(int i=0 ; i < l1 ; ++i){
    aux[i] = t1[i] ;
  } ;
  for(int i=0 ; i < l2 ; ++i){
    aux[l1+i] = t2[i] ;
  } ;
  for(int i=0 ; i < l3 ; ++i){
    aux[l1+l2+i] = t3[i] ;
  } ;
  real[] res = sort(aux,pp) ;
  return res ;
} ;

//la fonction quasi-finale étape par étape
real[] step(real[] config){
  real[] res ;
  
  int lc = next_crea(config[0]) ;
  real tc = haut ;
  if(lc < creas.length){
    tc = creas[lc].y ;
  } ;
  real tj = next_jump(config) ;

  real xx ;
  int lj = 0 ; //lj vaut 0 si c'est une crea, sinon le label de la particule qui jump

  if(tj <= tc){ //c'est un jump
    res[0] = tj ;
    lj = random_uniform_int(config.length-1) ; //label de la particule qui jump
    xx = config[lj] ;  
  } else { //c'est une crea
    res[0] = tc ;
    xx = creas[lc].x ;
  } ;

  //on dessine les lignes verticales
  draw_vert(config,res[0]) ;

  //on determine la fin et le type de fin
  real ff = fin_saut(config,xx) ;
  int kill = before_saut(config,xx,ff) ;
  if(kill > 0){
    ff = config[kill] ;
  } ;

  draw((xx,res[0])--(ff,res[0]),hori) ;
  //les survivants
  real[] memory = survive(config,xx,ff) ;

  //les nouveaux
  int nP = random_poisson(lambdaH*(ff-xx)) ;
  real[] poissonVert = random_ppp(nP,xx,ff) ;

  real[] debfin ;
  int j = 0 ;
  //rajout de xx
  if(lj > 0){
    if((lambdaV+tauV)*unitrand() < lambdaV){
      debfin[j] = xx ;
      j = j + 1 ;
    }
  } else {
    if(xx > 0){
      debfin[j] = xx ;
      j = j + 1 ;
    } ;
  } ;
  
  //rajout de fin
  if(kill > 0){
    if((p0+pV)*unitrand() < pV){
      debfin[j] = ff ;
    } ;
  } else {
    if(ff < larg){
      debfin[j] = ff ;
    } ;
  } ;

  //on concat et on trie
  real[] newElement = concatener(memory,poissonVert,debfin) ;
  for(int i = 1 ; i <= newElement.length ; ++i){
    res[i] = newElement[i-1] ;
  } ;
  
  //  real aux[] = concat
  return res ;

} ;

write(creas) ;
real[] part = config ;
for(int i=0 ; part[0] < haut ; ++i){
  write(part[0]) ;
  write(i) ;
  part = step(part) ;

}

draw((0,0)--(0,haut)--(larg,haut)--(larg,0)--cycle,white+linewidth(1pt)) ;


//int i = (1,0) ;



//real[] nvline = step(vline) ;
//real[] nnvline = step(nvline) ;
//real[] nnnvline = step(nvline) ;

//write(vline) ;
//write(nvline) ;





