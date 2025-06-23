open! Core
open! Core_unix

module type S = sig
  module Nbits : sig
    type t =
      | Single
      | Dual
      | Quad
      | Octal
    [@@deriving sexp]
  end

  module Spi_ioc_transfer : sig
    type t =
      { tx_buf: (read, Iobuf.no_seek) Iobuf.t option
      ; rx_buf: (write, Iobuf.no_seek) Iobuf.t option
      ; speed_hz: int option
      ; delay : Time_ns.Span.t
      ; bits_per_word: int option
      ; cs_change: bool
      ; tx_nbits: Nbits.t option
      ; rx_nbits: Nbits.t option
      ; word_delay: Time_ns.Span.t
      } [@@deriving sexp_of]

    val create
      :  ?speed_hz:int
      -> ?delay:Time_ns.Span.t
      -> ?bits_per_word:int
      -> ?cs_change:bool
      -> ?tx_nbits:Nbits.t
      -> ?rx_nbits:Nbits.t
      -> ?word_delay:Time_ns.Span.t
      -> tx_buf:(read, Iobuf.no_seek) Iobuf.t option
      -> rx_buf:(write, Iobuf.no_seek) Iobuf.t option
      -> unit
      -> t
  end

  val transfer 
    :  File_descr.t
    -> Spi_ioc_transfer.t array
    -> unit
end
