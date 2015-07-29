;PRO sc_man_data

;READ IN GALEX
;ais galex
       readcol,'../ais_frames/ais_allframes.txt',f='D,D,X,X,X,X,X,D',ra_ais,dec_ais,nuv_ais,delimiter='|'
;our galex
       restore,'repeats.sav'
       restore,'dec_nuv.sav'
       restore,'ra_nuv.sav'
       restore,'nuvmag.sav'
 ;combine all galex      
       ra_nuv_all=[ra_ais,ra_nuv]
       dec_nuv_all=[dec_ais,dec_nuv]
       nuvmag_all=[nuv_ais,nuvmag]

;READ IN WISE
readcol,'../WISE_fields/wise_reg4.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra4,dec4,w14,w1sig4,w24,w2sig4,w34,w3sig4,w44,w4sig4,ccf4,ex4,J4,H4,K4
readcol,'../WISE_fields/wise_reg2.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra2,dec2,w12,w1sig2,w22,w2sig2,w32,w3sig2,w42,w4sig2,ccf2,ex2,J2,H2,K2
readcol,'../WISE_fields/wise_reg1.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra1,dec1,w11,w1sig1,w21,w2sig1,w31,w3sig1,w41,w4sig1,ccf1,ex1,J1,H1,K1
readcol,'../WISE_fields/wise_reg3.tsv',f='X,d,d,X,X,X,X,X,X,X,f,f,f,f,f,f,f,f,f,X,f,X,f,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,A,f',ra3,dec3,w13,w1sig3,w23,w2sig3,w33,w3sig3,w43,w4sig3,J3,H3,K3,ccf3,ex3
readcol,'../WISE_fields/wise_reg5.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra5,dec5,w15,w1sig5,w25,w2sig5,w35,w3sig5,w45,w4sig5,ccf5,ex5,J5,H5,K5
readcol,'../WISE_fields/wise_reg6.tbl',f='X,d,d,X,X,X,f,f,X,X,f,f,X,X,f,f,X,X,f,f,X,X,X,X,X,X,X,X,A,f,X,X,X,X,X,X,X,X,X,X,X,f,X,f,X,f,X',ra6,dec6,w16,w1sig6,w26,w2sig6,w36,w3sig6,w46,w4sig6,ccf6,ex6,J6,H6,K6


ra_wise_tot      =      [ra1,ra2,ra3,ra4,ra5,ra6]
dec_wise_tot     =      [dec1,dec2,dec3,dec4,dec5,dec6]
w1_tot           =      [w11,w12,w13,w14,w15,w16]
w2_tot           =      [w21,w22,w23,w24,w25,w26]
w3_tot           =      [w31,w32,w33,w34,w35,w36]
w4_tot           =      [w41,w42,w43,w44,w45,w46]
j_tot            =      [j1,j2,j3,j4,j5,j6]
h_tot            =      [h1,h2,h3,h4,h5,h6]
k_tot            =      [k1,k2,k3,k4,k5,k6]
ccf_tot          =      [ccf1,ccf2,ccf3,ccf4,ccf5,ccf6]
ex_tot           =      [ex1,ex2,ex3,ex4,ex5,ex6]

xdel = where(ccf_tot eq '0000' and ex_tot eq 0) ;remove bad/iffy sources

ra_wise_all      =      ra_wise_tot[xdel]
dec_wise_all     =      dec_wise_tot[xdel]
w1_all           =      w1_tot[xdel]
w2_all           =      w2_tot[xdel]
w3_all           =      w3_tot[xdel]
w4_all           =      w4_tot[xdel]
j_all            =      j_tot[xdel]
h_all            =      h_tot[xdel]
k_all            =      k_tot[xdel]
ccf_all          =      ccf_tot[xdel]
ex_all           =      ex_tot[xdel] 


ra_wise = ra_wise_all / 15.0   
ra_nuv  = ra_nuv_all  / 15.0

srcor,ra_nuv,dec_nuv_all,ra_wise,dec_wise_all,5,ind1_new,ind2_new,option=1,spherical=1

ra_nuv_all = ra_nuv_all[ind1_new]
dec_nuv_all = dec_nuv_all[ind1_new]
ra_wise_all = ra_wise_all[ind2_new]
dec_wise_all = dec_wise_all[ind2_new]

plot,ra_nuv_all,dec_nuv_all,psym=3
plots,ra_wise_all,dec_wise_all,psym=3,color=255

nuvmag_all       =      nuvmag_all[ind1_new]
w1_all           =      w1_all[ind2_new]
w2_all           =      w2_all[ind2_new]
w3_all           =      w3_all[ind2_new]
w4_all           =      w4_all[ind2_new]
j_all            =      j_all[ind2_new]
h_all            =      h_all[ind2_new]
k_all            =      k_all[ind2_new]

save,filename='ra_nuv_all.sav'
save,filename='dec_nuv_all.sav'
save,filename='nuvmag_all.sav'
save,filename='ra_wise_all.sav'
save,filename='dec_wise_all.sav'
save,filename='w1_all.sav'
save,filename='w2_all.sav'
save,filename='w3_all.sav'
save,filename='w4_all.sav'
save,filename='j_all.sav'
save,filename='h_all.sav'
save,filename='k_all.sav'

END
