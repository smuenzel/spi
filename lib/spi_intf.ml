open! Core
open! Core_unix

module Nbits = struct
  type t =
    | Single
    | Dual
    | Quad
    | Octal
end


module type S = sig
  module Spi_ioc_transfer : sig
    type t =
      { tx_buf: (read, Iobuf.no_seek) Iobuf.t option
      ; rx_buf: (write, Iobuf.no_seek) Iobuf.t option
      ; speed_hz: int option
      ; delay : Time_ns.Span.t
      ; bits_per_word: int option
      ; tx_nbits: Nbits.t option
      ; rx_nbits: Nbits.t option
      ; word_delay: Time_ns.Span.t
      } [@@deriving sexp]
  end

  val transfer 
    :  File_descr.t
    -> Spi_ioc_transfer.t array
    -> unit
end
