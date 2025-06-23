open! Core
open! Core_unix

module Nbits = struct
  type t =
    | Single
    | Dual
    | Quad
    | Octal
  [@@deriving compare, equal, sexp]

  let to_value = function
    | Single -> 0x01
    | Dual -> 0x02
    | Quad -> 0x04
    | Octal -> 0x08
end

module Spi_ioc_transfer = struct
  type t =
    { tx_buf: (read, Iobuf.no_seek) Iobuf.Hexdump.t option
    ; rx_buf: (write, Iobuf.no_seek) Iobuf.Hexdump.t option
    ; speed_hz: int option
    ; delay : Time_ns.Span.t
    ; bits_per_word: int option
    ; cs_change: bool
    ; tx_nbits: Nbits.t option
    ; rx_nbits: Nbits.t option
    ; word_delay: Time_ns.Span.t
    } [@@deriving sexp_of]

  let create
      ?speed_hz
      ?(delay=Time_ns.Span.zero)
      ?bits_per_word
      ?(cs_change = false)
      ?tx_nbits
      ?rx_nbits
      ?(word_delay=Time_ns.Span.zero)
      ~tx_buf
      ~rx_buf
      ()
    =
    { tx_buf
    ; rx_buf
    ; speed_hz
    ; delay
    ; bits_per_word
    ; cs_change
    ; tx_nbits
    ; rx_nbits
    ; word_delay
    }

  module Raw = struct
    type t' = t

    [@@@ocaml.warning "-69"]

    type t =
      { tx_buf: (read, Iobuf.no_seek) Iobuf.Hexdump.t option
      ; rx_buf: (write, Iobuf.no_seek) Iobuf.Hexdump.t option
      ; len : int
      ; speed_hz : int
      ; delay : int
      ; bits_per_word : int
      ; cs_change : bool
      ; tx_nbits : int
      ; rx_nbits : int
      ; word_delay : int
      }

    let create (t' : t') : t =
      let len_tx = Option.map t'.tx_buf ~f:Iobuf.length in
      let len_rx = Option.map t'.rx_buf ~f:Iobuf.length in
      let len =
        match len_tx, len_rx with
        | Some len_tx, Some len_rx when len_tx = len_rx -> len_tx
        | Some len_tx, Some len_rx ->
          raise_s [%message "RX and TX length must be equal"
              (len_tx : int) (len_rx : int)]
        | Some len_tx, None -> len_tx
        | None, Some len_rx -> len_rx
        | None, None -> 0
      in
      { tx_buf = t'.tx_buf
      ; rx_buf = t'.rx_buf
      ; len
      ; speed_hz = Option.value t'.speed_hz ~default:0
      ; delay = Time_ns.Span.to_int_us t'.delay
      ; bits_per_word = Option.value t'.bits_per_word ~default:0
      ; cs_change = t'.cs_change
      ; tx_nbits = Option.value_map t'.tx_nbits ~default:0 ~f:Nbits.to_value
      ; rx_nbits = Option.value_map t'.rx_nbits ~default:0 ~f:Nbits.to_value
      ; word_delay = Time_ns.Span.to_int_us t'.word_delay
      }
  end

end

external spi_transfer_stub
  :  File_descr.t
  -> Spi_ioc_transfer.Raw.t array
  -> int
  = "spi_transfer_stub"


let transfer fd transfers =
  let return =
    spi_transfer_stub fd (Array.map transfers ~f:Spi_ioc_transfer.Raw.create)
  in
  assert (return = 0)
