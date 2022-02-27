module forces_module
use constantes



contains

subroutine LJ_potential(npart,positions,cutoff,length,pbc_on, Upot, force)

    !------------------------------------------------------------------------------------------------------------------------------!
    ! Codigo Daniel
    ! Información
    ! La subrutina calcula la energia potencial y la fuerza entre partículas, las cuales se encuentran sometidas a un potencial de Lennard-Jones.
    ! Variables de entrada:
    !   npart: número de partículas
    !   positions(npart,3): matriz de posiciones de las n_particulas
    !   cutoff: radio de interacción
    !   length: longitud de la caja
    !   pbc_on: en caso de ser 1, aplica condiciones periódicas de contorno
    ! Variables de salida:
    !   Upot: energia potencial del sistema
    !   force(npart,3): matriz para obtener la fuerza que aplica sobre cada partícula
    !------------------------------------------------------------------------------------------------------------------------------!

    implicit none
    integer, intent(in) :: npart, pbc_on
    double precision, intent(in) :: positions(npart,3), cutoff, length
    double precision :: Upot, force(npart,3)
    integer :: i, j, k
    double precision :: dr(3), dr2, dr6, dr8, dr12, dr14
   
    ! iniciamos la energia
    Upot = 0.0
    ! iniciamos la fuerza
    force = 0.d0
    ! bucle que recorre todas las interacciones
    do i = 1, npart-1
        do j = i+1, npart
        ! calculo de la diferencia entre las dos posciones
            do k = 1, 3
                dr(k) = positions(i,k) - positions(j,k)
            end do
            ! aplicamos condiciones periodicas de contorno 
            if(pbc_on == 1) call pbc(dr,length)
            ! calculamos la distancia
            dr2 = dr(1)**2 + dr(2)**2 + dr(3)**2
            ! calculamos la contribución si está dentro del cut-off
            if(dr2 <= cutoff**2) then
                dr6 = dr2**3
                dr8 = dr2**4
                dr12 = dr2**6
                dr14 = dr2**7
                ! energia potencial
                Upot = Upot + 4.d0*(1.d0/dr12 - 1.d0/dr6) - 4.d0*( 1.d0/cutoff**12 - 1.d0/cutoff**6)
                ! fuerza particula i
                force(i,1) = force(i,1) + (48.d0/dr14 - 24.d0/dr8)*dr(1)
                force(i,2) = force(i,2) + (48.d0/dr14 - 24.d0/dr8)*dr(2)
                force(i,3) = force(i,3) + (48.d0/dr14 - 24.d0/dr8)*dr(3)
                ! fuerza particula j
                force(j,1) = force(j,1) - (48.d0/dr14 - 24.d0/dr8)*dr(1)
                force(j,2) = force(j,2) - (48.d0/dr14 - 24.d0/dr8)*dr(2)
                force(j,3) = force(j,3) - (48.d0/dr14 - 24.d0/dr8)*dr(3)
            end if
        end do
    end do

    return
   
end subroutine LJ_potential

subroutine Kinetic_Energy(nparts,velocity,kin_E)

    !------------------------------------------------------------------------------------------------------------------------------!
    ! Codigo escrito por Daniel 
    ! InformacióN
    ! La subrutina calcula la energia cinetica de un sistema de partículas.
    ! Variables de entrada:
    !   nparts: número de partícules del sistema
    !   velocity(nparts,3): matriz que contiene la velocidad en cada direcció de cada partícula 
    ! Variables de salida:
    !   kin_E: energia cinética del sistema
    !------------------------------------------------------------------------------------------------------------------------------!

    implicit none
    ! variables de entrada y de salida
    integer, intent(in) :: nparts
    double precision, intent(in) :: velocity(nparts,3)
    double precision :: kin_E
    ! variables internas subrutina
    integer :: n, i
    double precision :: vel2
   
    kin_E = 0.d0
    do n = 1, nparts
        vel2 = 0.d0
        do i = 1, 3
            vel2 = vel2 + velocity(n,i)**2
        end do
        kin_E = kin_E + 0.5d0*vel2
    end do
   
    return
   
end subroutine Kinetic_Energy





subroutine pressure(n,rho,temp,l,cutoff,pos,pres)

    implicit none
    integer :: n
    double precision :: rho, temp, l, cutoff, pos(n,3)
    double precision :: pres
    integer :: i, j
    double precision :: dr(3), dr2, force(3)

    pres = 0.d0
    do i=1,n-1
        do j=i+1,n
            dr = pos(i,:)-pos(j,:)
            call pbc(dr,l)
            dr2 = sum(dr**2)
            if (dr2 < cutoff**2) then
                force = (48.d0/dr2**7 - 24.d0/dr2**4)*dr
                pres = pres + sum(dr*force)
            end if
        end do
    end do
    pres=pres+16/3.*pi*rho**2*(2/3.*(1./cutoff)**9)-(1/cutoff)**3/(1/(3*l**3))!Se añade para correcciones por cut-off
    pres = rho*temp + pres/(3.d0*l**3)

    return

end subroutine pressure


end module forces_module
